// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lzApp/NonblockingLzApp.sol";
import "forge-std/console.sol";

contract CrossChainDataFeedReceiver is NonblockingLzApp {
    uint256 public latestPrice;

    event PriceDataReceived(uint256);

    constructor(
        address _lzEndpoint,
        address _owner
    ) NonblockingLzApp(_lzEndpoint) Ownable(_owner) {}

    function _nonblockingLzReceive(
        uint16,
        bytes memory,
        uint64,
        bytes memory _payload
    ) internal override {
        uint256 price = abi.decode(_payload, (uint256));
        latestPrice = price;

        emit PriceDataReceived(price);
    }

    function getLatestCrossChainPrice() public view returns (uint256) {
        return latestPrice;
    }
}
