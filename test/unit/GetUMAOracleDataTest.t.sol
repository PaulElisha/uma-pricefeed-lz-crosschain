// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../mocks/UmaMock/MockOracle.sol";
import "../../src/02-UmaOptimisticOracleData/GetUMAOracleData.sol";
import "../mocks/UmaMock/MockTimer.sol";
import "../mocks/UmaMock/MockFinder.sol";
import "../mocks/UmaMock/MockIdentifierWhitelist.sol";
import "../mocks/UmaMock/MockToken.sol";

// import "../mocks/UmaMock/lib/OracleInterfaces.sol";

contract GetUMAOracleDataTest is Test {
    MockOracle mockOracle;
    MockTimer mockTimer;
    MockFinder mockFinder;
    MockIdentifierWhitelist mockIdentifierWhitelist;
    MockToken mockToken;
    GetUMAOracleData getUMAOracleData;

    bytes32 identifier = bytes32("YES_OR_NO_QUERY");

    function setUp() public {
        mockFinder = new MockFinder(address(this));
        mockTimer = new MockTimer();
        mockToken = new MockToken("mock", "mckt");
        mockIdentifierWhitelist = new MockIdentifierWhitelist(address(this));
        mockOracle = new MockOracle(address(mockFinder), address(mockTimer));
        getUMAOracleData = new GetUMAOracleData(
            address(mockOracle),
            address(mockToken)
        );

        vm.prank(mockIdentifierWhitelist.owner());
        mockIdentifierWhitelist.addSupportedIdentifier(
            OracleInterfaces.IdentifierWhitelist
        );

        vm.prank(mockFinder.owner());
        mockFinder.changeImplementationAddress(
            OracleInterfaces.IdentifierWhitelist,
            address(mockIdentifierWhitelist)
        );

        mockOracle.setVerifiedPrices(OracleInterfaces.IdentifierWhitelist, 120);
        mockOracle.setQueryIndex(OracleInterfaces.IdentifierWhitelist, 120);
    }

    function testRequestData() public {
        // Request price data
        vm.startPrank(address(0x2));
        getUMAOracleData.requestData();

        // Settle the request
        getUMAOracleData.settleRequest();

        // Get the settled data
        int256 data = getUMAOracleData.getSettledData();

        vm.stopPrank();
        console.log(data);
    }
}
