// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/AggregatorV3Interface.sol";

contract GetPriceFeedData {
    address public dataFeedAddress;

    function setDataFeedAddress(address _dataFeedAddress) public {
        dataFeedAddress = _dataFeedAddress;
    }

    function getPrice(address _dataFeed) public view returns (uint256) {
        AggregatorV3Interface dataFeed = AggregatorV3Interface(_dataFeed);
        (, int price, , , ) = dataFeed.latestRoundData();
        return uint256(price);
    }
}
