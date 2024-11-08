// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../../src/03-UmaOptimisticPriceData/GetUMAPriceData.sol";
import "../UMAPriceData/NetworkConfig.s.sol";
import "@uma/common/implementation/AddressWhitelist.sol";

contract DeployGetUMAPriceData is Script {
    GetUMAPriceData getUMAPriceData;
    NetworkConfig networkConfig;

    function run() public returns (GetUMAPriceData) {
        return deployGetUMAPriceData();
    }

    function deployGetUMAPriceData() public returns (GetUMAPriceData) {
        networkConfig = new NetworkConfig();
        // address lzEndpoint = networkConfig.getTestnetConfig().lzendpoint;
        address collateral = networkConfig.getTestnetConfig().collateral;
        address finder = networkConfig.getTestnetConfig().finder;
        bytes32 priceIdentifier = networkConfig
            .getTestnetConfig()
            .priceIdentifier;
        address timer = networkConfig.getTestnetConfig().timer;

        vm.startBroadcast();
        getUMAPriceData = new GetUMAPriceData(
            collateral,
            finder,
            priceIdentifier,
            timer
        );
        vm.stopBroadcast();

        return getUMAPriceData;
    }
}
