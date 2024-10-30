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

// import "../interfaces/OracleInterface.sol";

contract GetUMAPriceData is Testable, Lockable {
    // Unique identifier for price feed ticker.
    bytes32 private priceIdentifier;

    // Finder for UMA contracts.
    FinderInterface finder;

    // The collateral currency used to back the positions in this contract.
    IERC20 public collateralCurrency;

    constructor(
        address _collateralAddress,
        address _finderAddress,
        bytes32 _priceIdentifier,
        address _timerAddress
    ) nonReentrant() Testable(_timerAddress) {
        finder = FinderInterface(_finderAddress);
        require(
            _getIdentifierWhitelist().isIdentifierSupported(_priceIdentifier),
            "Unsupported price identifier"
        );
        require(
            _getAddressWhitelist().isOnWhitelist(_collateralAddress),
            "Unsupported collateral type"
        );
        collateralCurrency = IERC20(_collateralAddress);
        priceIdentifier = _priceIdentifier;
    }

    // Requests a price for `priceIdentifier` at `requestedTime` from the Optimistic Oracle.
    function requestOraclePrice(uint256 requestedTime) public {
        OptimisticOracleV2Interface oracle = _getOptimisticOracle();
        // For other use cases, you may need ancillary data or a reward. Here, they are both zero.
        oracle.requestPrice(
            priceIdentifier,
            requestedTime,
            "",
            IERC20(collateralCurrency),
            0
        );
    }

    function _getOptimisticOracle()
        internal
        view
        returns (OptimisticOracleV2Interface)
    {
        return
            OptimisticOracleV2Interface(
                finder.getImplementationAddress("OptimisticOracleV2")
            ); // TODO OracleInterfaces.OptimisticOracleV2
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

    // Fetches a resolved oracle price from the Optimistic Oracle. Reverts if the oracle hasn't resolved for this request.
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

        // For simplicity we don't want to deal with negative prices.
        if (oraclePrice < 0) {
            oraclePrice = 0;
        }
        return uint256(oraclePrice);
    }
}
