// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Constants {
    uint256 mainnetID = 8217;
    uint256 testnetID = 1001;
    uint16 localnetwork = 31337;

    int256 public constant INITIAL_ANSWER = 200_000_000_000;
    uint8 public constant DECIMAL = 8;
}
