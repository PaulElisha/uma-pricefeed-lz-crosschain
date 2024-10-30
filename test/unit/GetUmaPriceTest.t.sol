// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../script/UMAPriceData/DeployGetUMAPriceData.sol";
import "../../script/UMAPriceData/DeployUmaSender.s.sol";
import "../../src/03-UmaOptimisticPriceData/UmaSender.sol";
import "../../script/UMAPriceData/NetworkConfig.s.sol";

contract GetUmaPriceTest is Test {
    // DeployUmaSender deployUmaSender;
    NetworkConfig networkConfig;
    UmaSender umasender;
    uint256 public constant requestedTime = 30;

    uint16 public constant sepolia = uint16(uint256(11155111));

    function setUp() public {
        // deployUmaSender = new DeployUmaSender();
        networkConfig = new NetworkConfig();
        address endpoint = networkConfig.getTestnetConfig().lzendpoint;
        umasender = new UmaSender(endpoint, address(this));
    }

    function testRequestOraclePrice() public {
        umasender.sendPriceData(sepolia);
    }
}
