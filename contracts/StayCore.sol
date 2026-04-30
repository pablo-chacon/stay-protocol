// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "./Escrow.sol";

interface IEscrow {
  function fund(uint256 id, address token, uint256 amount, address payer) external payable;
  function releaseWithFees(
    uint256 id,
    address payee,
    address platformFeeTo, uint16 platformFeeBps,
    address protocolFeeTo, uint16 protocolFeeBps,
    address caller,        uint16 callerTipBps
  ) external;
  function refund(uint256 id, address to) external;
}

/**
 * @title StayCore
 * @notice STAY: neutral settlement rail for short-stay rentals.
 *
 * Neutral-rail invariants:
 * - Protocol fee is immutable 0.5% (50 bps), hard-coded.
 * - Auto-release is immutable 12 days, hard-coded.
 * - No owner, no governance, no admin switches.
 *
 * Out of scope: identity, KYC, taxes, cleaning, smart locks, reputation, arbitration.
 */
contract StayCore is EIP712 {
  using ECDSA for bytes32;

  uint16  public constant PROTOCOL_BPS     = 50;      // 0.5%
  uint256 public constant AUTO_RELEASE_DELAY   = 12 days; // 12 days
  uint16  public constant MAX_PLATFORM_FEE_BPS = 500;     // 5% cap for integrators

  enum State { None, Listed, Booked, Cancelled, Settled }

  struct Stay {
    address propertyContract;
    uint256 propertyId;

    address host;
    address guest;

    uint64  startTime;
    uint64  endTime;

    address paymentToken; // address(0) => ETH
    uint256 price;        // released to host (minus fees) on settlement
    uint256 deposit;      // refunded/released based on settlement intent (no fees by default)

    bytes32 checkinCommitment; // hash of check-in bundle
    bytes32 policyCommitment;  // hash/merkle root of cancellation + house rules + deposit policy

    address platformTreasury;
    uint16  platformFeeBps;

    uint64  bookedAt;     // set at booking; used for auto-release

    State   state;
  }

  IEscrow public immutable escrow;
  address public immutable protocolTreasury;

  mapping(uint256 => Stay) public stays;
  mapping(uint256 => uint256) public nonces; // settlement nonce per stayId

  function _priceLedger(uint256 stayId) internal pure returns (uint256) { return stayId << 1; }
  function _depositLedger(uint256 stayId) internal pure returns (uint256) { return (stayId << 1) | 1; }

  event ListingCreated(uint256 indexed stayId, address indexed host, address propertyContract, uint256 propertyId);
  event ListingCancelled(uint256 indexed stayId);
  event Booked(uint256 indexed stayId, address indexed guest);
  event Cancelled(uint256 indexed stayId);
  event Settled(uint256 indexed stayId, address indexed pricePayee, address indexed depositPayee, uint256 nonce);
  event AutoReleased(uint256 indexed stayId, address indexed caller, uint16 callerTipBps);

  bytes32 private constant SETTLE_TYPEHASH =
    keccak256(
      "Settle(uint256 stayId,address pricePayee,address depositPayee,address platformTreasury,uint16 platformFeeBps,uint16 callerTipBps,uint256 nonce,uint256 deadline)"
    );

  constructor(address protocolTreasury_) EIP712("STAY-Protocol", "1") {
    require(protocolTreasury_ != address(0), "bad-treasury");
    protocolTreasury = protocolTreasury_;

    // Deploy escrow inside core to avoid circular dependency while keeping core immutable in escrow.
    escrow = IEscrow(address(new Escrow(address(this))));
  }

  receive() external payable {}

  function createListing(
    uint256 stayId,
    address propertyContract,
    uint256 propertyId,
    uint64 startTime,
    uint64 endTime,
    address paymentToken,
    uint256 price,
    uint256 deposit,
    bytes32 checkinCommitment,
    bytes32 policyCommitment,
    address platformTreasury_,
    uint16  platformFeeBps_
  ) external {
    require(stays[stayId].state == State.None, "exists");
    require(propertyContract != address(0), "bad-property");
    require(endTime > startTime, "bad-window");
    require(price > 0, "price=0");

    require(IERC721(propertyContract).ownerOf(propertyId) == msg.sender, "not-owner");

    require(platformFeeBps_ <= MAX_PLATFORM_FEE_BPS, "platform-fee");
    if (platformFeeBps_ > 0) require(platformTreasury_ != address(0), "platform-to");

    stays[stayId] = Stay({
      propertyContract: propertyContract,
      propertyId: propertyId,
      host: msg.sender,
      guest: address(0),
      startTime: startTime,
      endTime: endTime,
      paymentToken: paymentToken,
      price: price,
      deposit: deposit,
      checkinCommitment: checkinCommitment,
      policyCommitment: policyCommitment,
      platformTreasury: platformTreasury_,
      platformFeeBps: platformFeeBps_,
      bookedAt: 0,
      state: State.Listed
    });

    emit ListingCreated(stayId, msg.sender, propertyContract, propertyId);
  }

  function cancelListing(uint256 stayId) external {
    Stay storage S = stays[stayId];
    require(S.host == msg.sender, "not-host");
    require(S.state == State.Listed, "bad-state");
    S.state = State.Cancelled;
    emit ListingCancelled(stayId);
  }

  function book(uint256 stayId) external payable {
    Stay storage S = stays[stayId];
    require(S.state == State.Listed, "bad-state");

    require(IERC721(S.propertyContract).ownerOf(S.propertyId) == S.host, "host-not-owner");

    S.guest = msg.sender;
    S.state = State.Booked;
    S.bookedAt = uint64(block.timestamp);

    uint256 total = S.price + S.deposit;

    if (S.paymentToken == address(0)) {
      require(msg.value == total, "bad-value");
      escrow.fund{value: S.price}(_priceLedger(stayId), address(0), S.price, msg.sender);
      if (S.deposit > 0) {
        escrow.fund{value: S.deposit}(_depositLedger(stayId), address(0), S.deposit, msg.sender);
      }
    } else {
      require(msg.value == 0, "no-eth");
      escrow.fund(_priceLedger(stayId), S.paymentToken, S.price, msg.sender);
      if (S.deposit > 0) {
        escrow.fund(_depositLedger(stayId), S.paymentToken, S.deposit, msg.sender);
      }
    }

    emit Booked(stayId, msg.sender);
  }

  function guestCancel(uint256 stayId) external {
    Stay storage S = stays[stayId];
    require(S.state == State.Booked, "bad-state");
    require(S.guest == msg.sender, "not-guest");

    escrow.refund(_priceLedger(stayId), S.guest);
    if (S.deposit > 0) escrow.refund(_depositLedger(stayId), S.guest);

    S.state = State.Cancelled;
    emit Cancelled(stayId);
  }

  function settle(
    uint256 stayId,
    address pricePayee,
    address depositPayee,
    uint16 callerTipBps,
    uint256 deadline,
    bytes calldata sigHost,
    bytes calldata sigGuest
  ) external {
    Stay storage S = stays[stayId];
    require(S.state == State.Booked, "bad-state");
    require(block.timestamp <= deadline, "expired");

    require(pricePayee != address(0), "bad-price-payee");
    require(depositPayee != address(0) || S.deposit == 0, "bad-deposit-payee");

    require(callerTipBps < 10000, "bad-tip-bps");
    require(uint32(callerTipBps) + uint32(S.platformFeeBps) + uint32(PROTOCOL_BPS) <= 10000, "total-bps");

    uint256 n = nonces[stayId];

    bytes32 structHash = keccak256(
      abi.encode(
        SETTLE_TYPEHASH,
        stayId,
        pricePayee,
        depositPayee,
        S.platformTreasury,
        S.platformFeeBps,
        callerTipBps,
        n,
        deadline
      )
    );

    bytes32 digest = _hashTypedDataV4(structHash);

    require(digest.recover(sigHost) == S.host,  "bad-sig-host");
    require(digest.recover(sigGuest) == S.guest, "bad-sig-guest");

    nonces[stayId] = n + 1;
    S.state = State.Settled;

    escrow.releaseWithFees(
      _priceLedger(stayId),
      pricePayee,
      S.platformTreasury, S.platformFeeBps,
      protocolTreasury,   PROTOCOL_BPS,
      msg.sender,         callerTipBps
    );

    if (S.deposit > 0) {
      escrow.refund(_depositLedger(stayId), depositPayee);
    }

    emit Settled(stayId, pricePayee, depositPayee, n);
  }

  /**
   * @notice Auto-release after 12 days from booking, permissionless.
   * @dev Neutral default:
   * - Price -> host (minus platform/protocol fees + optional caller tip)
   * - Deposit -> guest (refund) (no fees)
   */
  function autoRelease(uint256 stayId, uint16 callerTipBps) external {
    Stay storage S = stays[stayId];
    require(S.state == State.Booked, "bad-state");
    require(S.bookedAt != 0, "not-booked");
    require(block.timestamp >= uint256(S.bookedAt) + AUTO_RELEASE_DELAY, "too-early");

    require(callerTipBps < 10000, "bad-tip-bps");
    require(uint32(callerTipBps) + uint32(S.platformFeeBps) + uint32(PROTOCOL_BPS) <= 10000, "total-bps");

    uint256 n = nonces[stayId];
    nonces[stayId] = n + 1;
    S.state = State.Settled;

    escrow.releaseWithFees(
      _priceLedger(stayId),
      S.host,
      S.platformTreasury, S.platformFeeBps,
      protocolTreasury,   PROTOCOL_BPS,
      msg.sender,         callerTipBps
    );

    if (S.deposit > 0) {
      escrow.refund(_depositLedger(stayId), S.guest);
    }

    emit AutoReleased(stayId, msg.sender, callerTipBps);
    emit Settled(stayId, S.host, S.guest, n);
  }
}
