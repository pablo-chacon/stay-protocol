// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title PropertyRegistry
 * @notice Minimal ERC-721 identity registry for real-world accommodation units.
 *         Stores only integrity anchors (hashes) and an optional terms/metadata URI.
 *         All PII and operational details MUST remain off-chain.
 *
 * Neutral-rail posture:
 * - No admin controls, no blacklists, no governance.
 */
contract PropertyRegistry is ERC721 {
  struct Property {
    bytes32 unitHash;       // keccak256(unit_id || salt)
    bytes32 registryHash;   // keccak256(cadastre/registry || salt) (optional)
    bytes32 specHash;       // keccak256(canonical_json_specs)
    uint64  createdAt;
    string  termsURI;       // IPFS/HTTPS to terms + metadata bundle (non-PII recommended)
  }

  mapping(uint256 => Property) public properties;

  event PropertyMinted(
    uint256 indexed propertyId,
    address indexed owner,
    bytes32 unitHash,
    bytes32 registryHash,
    bytes32 specHash,
    string termsURI
  );

  constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

  function mint(
    uint256 propertyId,
    address to,
    bytes32 unitHash,
    bytes32 registryHash,
    bytes32 specHash,
    string calldata termsURI
  ) external {
    require(_ownerOf(propertyId) == address(0), "exists");
    require(to != address(0), "bad-to");
    require(unitHash != bytes32(0), "unitHash=0");
    require(specHash != bytes32(0), "specHash=0");

    _safeMint(to, propertyId);

    properties[propertyId] = Property({
      unitHash: unitHash,
      registryHash: registryHash,
      specHash: specHash,
      createdAt: uint64(block.timestamp),
      termsURI: termsURI
    });

    emit PropertyMinted(propertyId, to, unitHash, registryHash, specHash, termsURI);
  }

  function setTermsURI(uint256 propertyId, string calldata newTermsURI) external {
    require(ownerOf(propertyId) == msg.sender, "not-owner");
    properties[propertyId].termsURI = newTermsURI;
  }
}
