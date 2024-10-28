// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../mocks/MockOracle.sol";
import "../../src/UmaOptimisticOracleData/GetUMAOracleData.sol";
import "../../src/UmaOptimisticOracleData/Finder.sol";
import "@uma/common/implementation/Timer.sol";
import "../mocks/MockToken.sol";

contract GetUMAOracleDataTest is Test {
    GetUMAOracleData getUMAOracleData;
    MockOracle mockOracle;
    Finder finder;
    Timer timer;
    MockToken mockERC20;

    bytes32 identifier = bytes32("YES_OR_NO_QUERY");

    function setUp() public {
        getUMAOracleData = new GetUMAOracleData();
        finder = new Finder(address(this));
        timer = new Timer();
        mockOracle = new MockOracle(address(finder), address(timer));
        mockERC20 = new MockToken("mock", "mckt");

        // Set the Oracle Address
        getUMAOracleData.setUMAOracleAddress(address(mockOracle));

        mockOracle.setVerifiedPrices(identifier, 120);
        mockOracle.setQueryIndex(identifier, 120);
        mockOracle.setQueryPoint(identifier, 120);
    }

    function testRequestData() public {
        // Request price data
        getUMAOracleData.requestData(
            getUMAOracleData.optimisticOracleAddress(),
            address(mockERC20)
        );

        // Settle the request
        getUMAOracleData.settleRequest(address(mockOracle));

        // Get the settled data
        int256 data = getUMAOracleData.getSettledData(address(mockOracle));
        console.log(data);
    }
}
