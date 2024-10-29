// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GetUMAOracleData.sol";
import "../lzApp/NonblockingLzApp.sol";

contract UMASender is NonblockingLzApp {
    GetUMAOracleData getUMAOracleData;

    event DataSent();

    constructor(
        address _lzEndpoint,
        address _deployer
    ) NonblockingLzApp(_lzEndpoint) Ownable(_deployer) {
        getUMAOracleData = new GetUMAOracleData();
    }

    function sendPriceData(
        uint16 _dstChainid,
        address oracleAddress
    ) public payable {
        getUMAOracleData.setOracleAddress(oracleAddress);

        getUMAOracleData.requestData(getUMAOracleData.oracleAddress());
        int256 priceData = getUMAOracleData.getPriceData();

        bytes memory payload = abi.encode(priceData);
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
        emit DataSent();
    }
}
