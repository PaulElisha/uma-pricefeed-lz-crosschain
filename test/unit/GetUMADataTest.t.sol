// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../mocks/ChainlinkDataMock/LZendpointMock.sol";
import "../../src/02-UmaOptimisticOracleData/UMASender.sol";
import "../../src/02-UmaOptimisticOracleData/UMAReceiver.sol";
import "../../script/Constants.s.sol";

contract CrossChainDataFeedTest is Test, Constants {
    LZEndpointMock lzEndpointMock;
    UMASender sender;
    UMAReceiver receiver;

    function setUp() public {
        hoax(address(0x1), 10 ether);

        lzEndpointMock = new LZEndpointMock(localnetwork);

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

    function testEthToKaia() public {
        hoax(address(0x4), 10 ether);
        sender.sendPriceData{value: 1 ether}(localnetwork);

        console.log(mockV3Aggregator.version());
        console.log(receiver.getLatestCrossChainPrice());
    }
}
