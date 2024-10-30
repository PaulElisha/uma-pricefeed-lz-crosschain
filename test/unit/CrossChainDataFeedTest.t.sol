// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../mocks/LZendpointMock.sol";
import "../../src/01-ChainlinkPriceData/CrossChainDataFeedSender.sol";
import "../../src/01-ChainlinkPriceData/CrossChainDataFeedReceiver.sol";
import {MockV3Aggregator} from "../mocks/ChainlinkDataMock/MockV3Aggregator.sol";
import "../../script/Constants.s.sol";

contract CrossChainDataFeedTest is Test, Constants {
    LZEndpointMock lzEndpointMock;
    CrossChainDataFeedSender sender;
    CrossChainDataFeedReceiver receiver;
    MockV3Aggregator mockV3Aggregator;

    function setUp() public {
        hoax(address(0x1), 10 ether);

        mockV3Aggregator = new MockV3Aggregator(DECIMAL, INITIAL_ANSWER);

        lzEndpointMock = new LZEndpointMock(localnetwork);

        vm.prank(address(0x2));

        sender = new CrossChainDataFeedSender(
            address(lzEndpointMock),
            address(0x2)
        );

        hoax(address(0x3), 10 ether);

        receiver = new CrossChainDataFeedReceiver(
            address(lzEndpointMock),
            address(0x3)
        );

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
        sender.sendPriceData{value: 1 ether}(
            localnetwork,
            address(mockV3Aggregator)
        );

        console.log(mockV3Aggregator.version());
        console.log(receiver.getLatestCrossChainPrice());
    }
}
