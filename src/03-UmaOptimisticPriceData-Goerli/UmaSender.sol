// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../03-UmaOptimisticPriceData-Goerli/GetUMAPriceData.sol";
import "../../script/UMAPriceData/NetworkConfig.s.sol";
import "../lzApp/NonblockingLzApp.sol";

contract UMASender is NonblockingLzApp {
    GetUMAPriceData getUMAPriceData;
    uint256 public constant requestedTime = 30;

    NetworkConfig networkConfig;

    event DataSent();

    constructor(
        address _lzEndpoint,
        address _deployer
    ) NonblockingLzApp(_lzEndpoint) Ownable(_deployer) {
        networkConfig = new NetworkConfig();
        address collateral = networkConfig.getTestnetConfig().collateral;
        bytes32 priceIdentifier = networkConfig
            .getTestnetConfig()
            .priceIdentifier;
        address finder = networkConfig.getTestnetConfig().finder;
        address timer = networkConfig.getTestnetConfig().timer;

        getUMAPriceData = new GetUMAPriceData(
            collateral,
            finder,
            priceIdentifier,
            timer
        );
    }

    function sendPriceData(uint16 _dstChainid) public payable {
        getUMAPriceData.requestOraclePrice(requestedTime);
        uint256 priceData = getUMAPriceData.getOraclePrice(requestedTime);

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
