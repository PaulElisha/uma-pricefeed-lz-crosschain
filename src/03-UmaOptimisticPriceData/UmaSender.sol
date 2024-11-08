// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../script/UMAPriceData/DeployGetUMAPriceData.sol";
import "../lzApp/NonblockingLzApp.sol";
import "../../script/Constants.s.sol";

contract UmaSender is NonblockingLzApp, Constants {
    DeployGetUMAPriceData deployGetUMAPriceData;
    GetUMAPriceData getUMAPriceData;

    event DataSent();

    constructor(
        address _lzEndpoint,
        address _deployer
    ) NonblockingLzApp(_lzEndpoint) Ownable(_deployer) {}

    function sendPriceData(uint16 _dstChainid) public payable {
        deployGetUMAPriceData = new DeployGetUMAPriceData();
        getUMAPriceData = deployGetUMAPriceData.run();

        getUMAPriceData.requestOraclePrice(requestedTime);
        uint256 priceData = getUMAPriceData.getOraclePrice(requestedTime);

        bytes memory payload = abi.encode(priceData);
        bytes memory adapterParams = abi.encodePacked(
            uint256(1),
            uint256(20000)
        );

        _lzSend(
            _dstChainid,
            payload,
            payable(msg.sender),
            address(0),
            adapterParams,
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
