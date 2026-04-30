// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

import "../contracts/PropertyRegistry.sol";
import "../contracts/StayCore.sol";

/**
 * ENV:
 * - DEPLOYER_KEY (uint)
 * - PROTOCOL_TREASURY (address)   // your Safe
 */
contract DeployProtocol is Script {
  function run() external {
    uint256 deployerKey = vm.envUint("PRIVATE_KEY");
    address protocolTreasury = vm.envAddress("PROTOCOL_TREASURY");

    vm.startBroadcast(deployerKey);

    PropertyRegistry registry = new PropertyRegistry("DeBNB Property Registry", "DEBNB-PROP");
    StayCore core = new StayCore(protocolTreasury);

    vm.stopBroadcast();

    registry;
    core;
  }
}
