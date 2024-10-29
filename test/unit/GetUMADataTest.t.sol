// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../mocks/ChainlinkDataMock/LZendpointMock.sol";
import "../../src/02-UMAOptimisticOracleData/UMASender.sol";
import "../../src/02-UMAOptimisticOracleData/UMAReceiver.sol";
import "../mocks/UmaMock/MockOracle.sol";
import "../mocks/UmaMock/MockIdentifierWhitelist.sol";
import "../mocks/UmaMock/MockFinder.sol";
import "../mocks/UmaMock/MockTimer.sol";
// import "../mocks/UmaMock/lib/OracleInterfaces.sol";
import "../../script/Constants.s.sol";

contract GetUMADataTest is Test, Constants {
    LZEndpointMock lzEndpointMock;
    UMASender sender;
    UMAReceiver receiver;
    MockOracle mockOracle;
    MockIdentifierWhitelist mockIdentifierWhitelist;
    MockFinder mockFinder;
    MockTimer mockTimer;

    bytes32 public identifier = "ETH/USD";

    function setUp() public {
        mockFinder = new MockFinder(address(this));
        mockTimer = new MockTimer();
        mockIdentifierWhitelist = new MockIdentifierWhitelist(address(this));

        vm.prank(mockFinder.owner());

        mockFinder.changeImplementationAddress(
            OracleInterfaces.IdentifierWhitelist,
            address(mockIdentifierWhitelist)
        );

        hoax(address(0x1), 10 ether);

        mockOracle = new MockOracle(address(mockFinder), address(mockTimer));

        lzEndpointMock = new LZEndpointMock(localnetwork);

        mockOracle.setVerifiedPrices(identifier, block.timestamp);
        mockOracle.setQueryIndex(identifier, block.timestamp);

        vm.prank(address(0x2));

        sender = new UMASender(address(lzEndpointMock), address(0x2));

        hoax(address(0x3), 10 ether);

        receiver = new UMAReceiver(address(lzEndpointMock), address(0x3));

        vm.deal(address(lzEndpointMock), 10 ether);
        vm.deal(address(sender), 10 ether);
        vm.deal(address(receiver), 10 ether);

        bytes memory sender_address = abi.encodePacked(
            uint160(address(sender))
        );

        bytes memory receiver_address = abi.encodePacked(
            uint160(address(receiver))
        );

        vm.startPrank(address(0x1));
        lzEndpointMock.setDestLzEndpoint(
            address(sender),
            address(lzEndpointMock)
        );

        lzEndpointMock.setDestLzEndpoint(
            address(receiver),
            address(lzEndpointMock)
        );

        vm.stopPrank();

        vm.prank(address(0x2));
        sender.setTrustedRemoteAddress(localnetwork, sender_address);

        vm.prank(address(0x3));
        receiver.setTrustedRemoteAddress(localnetwork, receiver_address);
    }

    function testSepoliaToKaia() public {
        hoax(address(0x4), 10 ether);
        sender.sendPriceData{value: 1 ether}(localnetwork, address(mockOracle));

        console.log(receiver.getLatestCrossChainPrice());
    }
}
