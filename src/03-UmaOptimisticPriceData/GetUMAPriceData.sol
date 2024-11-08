// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@uma/common/implementation/AddressWhitelist.sol";
import "@uma/common/implementation/Testable.sol";
import "@uma/common/implementation/Lockable.sol";

import "@uma/oracle/interfaces/FinderInterface.sol";
import "@uma/oracle/interfaces/IdentifierWhitelistInterface.sol";
import "./interfaces/OptimisticOracleV2Interface.sol";
import "../../test/mocks/UmaMock/lib/OracleInterfaces.sol";

contract GetUMAPriceData is Testable, Lockable {
    bytes32 private priceIdentifier;

    FinderInterface finder;

    IERC20 public collateralCurrency;

    constructor(
        address _collateralAddress,
        address _finderAddress,
        bytes32 _priceIdentifier,
        address _timerAddress
    ) nonReentrant() Testable(_timerAddress) {
        finder = FinderInterface(_finderAddress);
        // require(
        //     _getIdentifierWhitelist().isIdentifierSupported(_priceIdentifier),
        //     "Unsupported price identifier"
        // );
        // require(
        //     _getAddressWhitelist().isOnWhitelist(_collateralAddress),
        //     "Unsupported collateral type"
        // );
        collateralCurrency = IERC20(_collateralAddress);
        priceIdentifier = _priceIdentifier;
    }

    function requestOraclePrice(uint256 requestedTime) public {
        OptimisticOracleV2Interface oracle = _getOptimisticOracle();
        oracle.requestPrice(
            priceIdentifier,
            requestedTime,
            "",
            IERC20(collateralCurrency),
            0
        );
    }

    function getOraclePrice(
        uint256 withdrawalRequestTimestamp
    ) public returns (uint256) {
        OptimisticOracleV2Interface oracle = _getOptimisticOracle();
        require(
            oracle.hasPrice(
                address(this),
                priceIdentifier,
                withdrawalRequestTimestamp,
                ""
            ),
            "Unresolved oracle price"
        );
        int256 oraclePrice = oracle.settleAndGetPrice(
            priceIdentifier,
            withdrawalRequestTimestamp,
            ""
        );

        if (oraclePrice < 0) {
            oraclePrice = 0;
        }
        return uint256(oraclePrice);
    }

    function _getOptimisticOracle()
        internal
        view
        returns (OptimisticOracleV2Interface)
    {
        return
            OptimisticOracleV2Interface(
                finder.getImplementationAddress("OptimisticOracleV2")
            );
    }

    function _getIdentifierWhitelist()
        internal
        view
        returns (IdentifierWhitelistInterface)
    {
        return
            IdentifierWhitelistInterface(
                finder.getImplementationAddress(
                    OracleInterfaces.IdentifierWhitelist
                )
            );
    }

    function _getAddressWhitelist() internal view returns (AddressWhitelist) {
        return
            AddressWhitelist(
                finder.getImplementationAddress(
                    OracleInterfaces.CollateralWhitelist
                )
            );
    }
}
