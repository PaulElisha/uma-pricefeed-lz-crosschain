// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../src/03-UmaOptimisticPriceData/UmaSender.sol";
import "../../script/UMAPriceData/NetworkConfig.s.sol";

contract DeployUmaSender is Script {
    UmaSender sender;
    NetworkConfig networkConfig;

    function run() public returns (UmaSender) {
        return deployUmaSender();
    }

    function deployUmaSender() public returns (UmaSender) {
        networkConfig = new NetworkConfig();
        address endpoint = networkConfig.getTestnetConfig().lzendpoint;

        vm.startBroadcast();
        sender = new UmaSender(endpoint, address(this));
        vm.stopBroadcast();

        return sender;
    }
}
