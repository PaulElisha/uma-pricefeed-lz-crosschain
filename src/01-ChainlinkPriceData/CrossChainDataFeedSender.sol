// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GetPriceFeedData.sol";
import "../lzApp/NonblockingLzApp.sol";

contract CrossChainDataFeedSender is NonblockingLzApp {
    GetPriceFeedData getPricefeedData;

    event PriceDataSent();

    constructor(
        address _lzEndpoint,
        address _deployer
    ) NonblockingLzApp(_lzEndpoint) Ownable(_deployer) {
        getPricefeedData = new GetPriceFeedData();
    }

    function sendPriceData(
        uint16 _dstChainid,
        address pricefeedAddress
    ) public payable {
        getPricefeedData.setDataFeedAddress(pricefeedAddress);

        uint256 price = getPricefeedData.getPrice(
            getPricefeedData.dataFeedAddress()
        );

        bytes memory payload = abi.encode(price);
        // bytes memory adapterParams = abi.encodePacked(
        //     uint256(1),
        //     uint256(20000)
        // );

        _lzSend(
            _dstChainid,
            payload,
            payable(msg.sender),
            address(0),
            hex"",
            msg.value
        );
    }

    function _nonblockingLzReceive(
        uint16,
        bytes memory,
        uint64,
        bytes memory
    ) internal override {
        emit PriceDataSent();
    }
}
