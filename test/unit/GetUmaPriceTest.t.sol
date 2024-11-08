// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../script/UMAPriceData/DeployUmaSender.s.sol";
import "../../src/03-UmaOptimisticPriceData/UmaSender.sol";

contract GetUmaPriceTest is Test, Constants {
    DeployUmaSender deployUmaSender;
    UmaSender umasender;

    uint16 testnet = uint16(testnetID);
    uint256 internal testnetFork;

    uint256 privateKey;
    address user;

    function setUp() public {
        deployUmaSender = new DeployUmaSender();
        umasender = deployUmaSender.run();

        privateKey = vm.envUint("private_key");
        user = vm.addr(privateKey);

        testnetFork = vm.createFork(sepolia_testnet);
        vm.selectFork(testnetFork);
    }

    function testRequestOraclePrice() public {
        // vm.prank(user);
        umasender.sendPriceData(testnet);
        // vm.stopPrank();
    }
}
