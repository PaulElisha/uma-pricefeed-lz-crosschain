// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lzApp/NonblockingLzApp.sol";
import "forge-std/console.sol";

contract UMAReceiver is NonblockingLzApp {
    int256 public data;

    event PriceDataReceived(int256);

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
        int256 _data = abi.decode(_payload, (int256));
        data = _data;

        emit PriceDataReceived(_data);
    }

    function getLatestCrossChainPrice() public view returns (int256) {
        return data;
    }
}
