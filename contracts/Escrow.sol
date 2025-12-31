// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title Escrow
 * @notice Generic single-ledger escrow used by protocol cores.
 *         Stores funds per id, then releases with fee splits or refunds.
 *
 * Neutral-rail invariant:
 * - `core` is immutable and can never be changed after deployment.
 */
contract Escrow {
  using SafeERC20 for IERC20;

  address public immutable core;

  struct Ledger {
    address token;   // address(0) => ETH
    uint256 amount;
    address payer;
    bool    paid;
    bool    released;
  }

  mapping(uint256 => Ledger) public ledgers;

  modifier onlyCore() {
    require(msg.sender == core, "not-core");
    _;
  }

  constructor(address core_) {
    require(core_ != address(0), "bad-core");
    core = core_;
  }

  function fund(
    uint256 id,
    address token,
    uint256 amount,
    address payer
  ) external payable onlyCore {
    Ledger storage L = ledgers[id];
    require(!L.paid, "already-funded");
    require(amount > 0, "amount=0");

    L.token  = token;
    L.amount = amount;
    L.payer  = payer;
    L.paid   = true;

    if (token == address(0)) {
      require(msg.value == amount, "bad-value");
    } else {
      require(msg.value == 0, "no-eth");
      IERC20(token).safeTransferFrom(payer, address(this), amount);
    }
  }

  function releaseWithFees(
    uint256 id,
    address payee,
    address platformFeeTo, uint16 platformFeeBps,
    address protocolFeeTo, uint16 protocolFeeBps,
    address caller,        uint16 callerTipBps
  ) external onlyCore {
    Ledger storage L = ledgers[id];
    require(L.paid && !L.released, "bad-ledger");
    L.released = true;

    require(platformFeeBps < 10000 && protocolFeeBps < 10000 && callerTipBps < 10000, "bps");
    require(
      uint32(platformFeeBps) + uint32(protocolFeeBps) + uint32(callerTipBps) <= 10000,
      "total-bps"
    );

    uint256 p = (L.amount * platformFeeBps) / 10000;
    uint256 r = (L.amount * protocolFeeBps) / 10000;
    uint256 t = (L.amount * callerTipBps)   / 10000;
    uint256 v = L.amount - p - r - t;

    if (L.token == address(0)) {
      if (p > 0) Address.sendValue(payable(platformFeeTo), p);
      if (r > 0) Address.sendValue(payable(protocolFeeTo), r);
      if (t > 0) Address.sendValue(payable(caller),        t);
      Address.sendValue(payable(payee), v);
    } else {
      IERC20 tok = IERC20(L.token);
      if (p > 0) tok.safeTransfer(platformFeeTo, p);
      if (r > 0) tok.safeTransfer(protocolFeeTo, r);
      if (t > 0) tok.safeTransfer(caller,        t);
      tok.safeTransfer(payee, v);
    }
  }

  function refund(uint256 id, address to) external onlyCore {
    Ledger storage L = ledgers[id];
    require(L.paid && !L.released, "bad-ledger");
    L.released = true;

    if (L.token == address(0)) {
      Address.sendValue(payable(to), L.amount);
    } else {
      IERC20(L.token).safeTransfer(to, L.amount);
    }
  }
}
