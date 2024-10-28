// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/OptimisticOracleV2Interface.sol";

contract GetUMAOracleData {
    // Create an Optimistic oracle instance at the deployed address on Görli.
    address public optimisticOracleAddress;

    // Use the yes no idetifier to ask arbitary questions, such as the weather on a particular day.
    bytes32 identifier = bytes32("YES_OR_NO_QUERY");

    // Post the question in ancillary data. Note that this is a simplified form of ancillry data to work as an example. A real
    // world prodition market would use something slightly more complex and would need to conform to a more robust structure.
    bytes ancillaryData =
        bytes(
            "Q:Did the temperature on the 25th of July 2022 in Manhattan NY exceed 35c? A:1 for yes. 0 for no."
        );

    uint256 requestTime = 0; // Store the request time so we can re-use it later.

    function setUMAOracleAddress(address _oracle) public {
        optimisticOracleAddress = _oracle;
    }

    // Submit a data request to the Optimistic oracle.
    function requestData(address _oracleAddress, address _token) public {
        requestTime = block.timestamp; // Set the request time to the current block time.
        IERC20 bondCurrency = IERC20(_token); // Use Görli WETH as the bond currency.
        uint256 reward = 0; // Set the reward to 0 (so we dont have to fund it from this contract).

        OptimisticOracleV2Interface oo = OptimisticOracleV2Interface(
            _oracleAddress
        );
        // Now, make the price request to the Optimistic oracle and set the liveness to 30 so it will settle quickly.
        oo.requestPrice(
            identifier,
            requestTime,
            ancillaryData,
            bondCurrency,
            reward
        );
        oo.setCustomLiveness(identifier, requestTime, ancillaryData, 30);
    }

    // Settle the request once it's gone through the liveness period of 30 seconds. This acts the finalize the voted on price.
    // In a real world use of the Optimistic Oracle this should be longer to give time to disputers to catch bat price proposals.
    function settleRequest(address _oracleAddress) public {
        OptimisticOracleV2Interface oo = OptimisticOracleV2Interface(
            _oracleAddress
        );
        oo.settle(address(this), identifier, requestTime, ancillaryData);
    }

    // Fetch the resolved price from the Optimistic Oracle that was settled.
    function getSettledData(
        address _oracleAddress
    ) public view returns (int256) {
        OptimisticOracleV2Interface oo = OptimisticOracleV2Interface(
            _oracleAddress
        );
        return
            oo
                .getRequest(
                    address(this),
                    identifier,
                    requestTime,
                    ancillaryData
                )
                .resolvedPrice;
    }
}
