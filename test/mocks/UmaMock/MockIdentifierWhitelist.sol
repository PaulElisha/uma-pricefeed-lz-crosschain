// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "@uma/oracle/interfaces/IdentifierWhitelistInterface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Stores a whitelist of supported identifiers that the oracle can provide prices for.
 */
contract MockIdentifierWhitelist is IdentifierWhitelistInterface, Ownable {
    /****************************************
     *     INTERNAL VARIABLES AND STORAGE   *
     ****************************************/

    mapping(bytes32 => bool) private supportedIdentifiers;

    /****************************************
     *                EVENTS                *
     ****************************************/

    constructor(address _initialOwner) Ownable(_initialOwner) {}

    event SupportedIdentifierAdded(bytes32 indexed identifier);
    event SupportedIdentifierRemoved(bytes32 indexed identifier);

    /****************************************
     *    ADMIN STATE MODIFYING FUNCTIONS   *
     ****************************************/

    /**
     * @notice Adds the provided identifier as a supported identifier.
     * @dev Price requests using this identifier will succeed after this call.
     * @param identifier unique UTF-8 representation for the feed being added. Eg: BTC/USD.
     */
    function addSupportedIdentifier(
        bytes32 identifier
    ) external override onlyOwner {
        if (!supportedIdentifiers[identifier]) {
            supportedIdentifiers[identifier] = true;
            emit SupportedIdentifierAdded(identifier);
        }
    }

    /**
     * @notice Removes the identifier from the whitelist.
     * @dev Price requests using this identifier will no longer succeed after this call.
     * @param identifier unique UTF-8 representation for the feed being removed. Eg: BTC/USD.
     */
    function removeSupportedIdentifier(
        bytes32 identifier
    ) external override onlyOwner {
        if (supportedIdentifiers[identifier]) {
            supportedIdentifiers[identifier] = false;
            emit SupportedIdentifierRemoved(identifier);
        }
    }

    /****************************************
     *     WHITELIST GETTERS FUNCTIONS      *
     ****************************************/

    function isIdentifierSupported(
        bytes32 identifier
    ) external view returns (bool) {
        return supportedIdentifiers[identifier];
    }
}
