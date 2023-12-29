// SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

contract FallbackExample {
    uint256 public result;

    /// receive()
    // Receive is a special function which allows the contract to receive a transaction even though no function was called
    // receive function is triggered any time a transaction is sent to the contract even though the transferred value is 0, 
    // as long as there are no data associated to the transaction
    receive() external payable {
        result = 1;
    }

    /// fallback()
    // Fallback works very similarly to receive() with the main difference that can accept data
    fallback() external payable {
        result = 2;
    }
}