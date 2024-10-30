// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../script/UMAPriceData/DeployGetUMAPriceData.sol";
import "../../src/03-UmaOptimisticPriceData-Goerli/GetUMAPriceData.sol";

contract GetUMAPriceDataTest is Test {
    DeployGetUMAPriceData deployGetUMAPriceData;
    GetUMAPriceData getUMAPriceData;
    uint256 public constant requestedTime = 30;

    function setUp() public {
        deployGetUMAPriceData = new DeployGetUMAPriceData();
        getUMAPriceData = deployGetUMAPriceData.run();
    }

    function testRequestOraclePrice() public {
        getUMAPriceData.requestOraclePrice(requestedTime);
    }
}
