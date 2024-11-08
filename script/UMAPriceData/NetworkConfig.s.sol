// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "./../Constants.s.sol";
import "../../test/mocks/LZEndpointMock.sol";
import "../../test/mocks/UmaMock/MockTimer.sol";
import "../../test/mocks/UmaMock/MockFinder.sol";
import "./CollateralToken.sol";

contract NetworkConfig is Script, Constants {
    CollateralToken collateralToken;
    MockTimer mockTimer;
    MockFinder mockFinder;
    struct Config {
        address lzendpoint;
        address collateral;
        address finder;
        address timer;
        bytes32 priceIdentifier;
    }

    mapping(uint256 => Config) private configs;

    // function _getConfigByChainID(
    //     uint256 chainid
    // ) public returns (Config memory) {
    //     if (chainid == testnetID) {
    //         return getTestnetConfig();
    //     }
    // }

    // function getConfig() public returns (Config memory) {
    //     return _getConfigByChainID(block.chainid);
    // }

    // function getMainnetConfig() public view returns (Config memory) {
    //     Config memory config = configs[mainnetID];
    //     config.lzendpoint = 0x1a44076050125825900e736c501f859c50fE728c;

    //     return config;
    // }

    function getTestnetConfig() public returns (Config memory) {
        vm.startBroadcast();
        collateralToken = new CollateralToken("CollateralToken", "CO");
        // mockTimer = new MockTimer();
        vm.stopBroadcast();

        Config memory config = configs[testnetID];

        config.lzendpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        config.collateral = address(collateralToken);
        config.finder = 0xf4C48eDAd256326086AEfbd1A53e1896815F8f13;
        config.priceIdentifier = "ETH/USD";

        config.timer = address(0x0);

        return config;
    }
}
