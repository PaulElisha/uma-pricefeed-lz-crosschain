// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "../../test/mocks/UmaMock/MockOracle.sol";

// import "../interfaces/OracleInterface.sol";

contract GetUMAOracleData {
    address public oracleAddress;
    bytes32 public identifier = "ETH/USD";
    int256 priceData;

    uint256 requestTime = 0; // Store the request time so we can re-use it later.

    function setOracleAddress(address _oracle) public {
        oracleAddress = _oracle;
    }

    // Submit a data request to the Optimistic oracle.
    function requestData(address _oracleAddress) public {
        requestTime = block.timestamp; // Set the request time to the current block time.

        // Now, make the price request to the Optimistic oracle and set the liveness to 30 so it will settle quickly.
        OracleInterface oracle = OracleInterface(_oracleAddress);
        oracle.requestPrice(identifier, requestTime);
        require(oracle.hasPrice(identifier, requestTime));
        int256 price = oracle.getPrice(identifier, requestTime);

        priceData = price;
    }

    // Fetch the resolved price from the Optimistic Oracle that was settled.
    function getPriceData() public view returns (int256) {
        return priceData;
    }
}
