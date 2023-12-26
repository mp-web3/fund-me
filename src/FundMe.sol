// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// Allow users to send funds to the contract and require a minimum of 1 ETH
contract FundMe {
    function fund() public payable {
        require(msg.value > 1e18, "Minimum of 1 ETH");
    }
}