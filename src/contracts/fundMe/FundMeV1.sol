// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {PriceConverter} from "../../lib/priceConverter";

// Allow users to send funds to the contract and require a minimum of 1 ETH
contract FundMe {

    // Attach the functions in PriceConverter.sol to all uint256
    using PriceConverter for uint256;
    uint256 public minimumUSD = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;


    address public owner;

    constructor () {
        owner = msg.sender;
    }

    modifier onlyOwner () {
        require (msg.sender == owner, "Caller is not the Owner"); 
        _;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= minimumUSD, "Didn't send enough eth. The eth amount sent should be equal or greater than the equivalent of 5$");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    // Withdraw all funds
    function withdraw() public onlyOwner {
        // Set all amountFunded to 0
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex ++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // Reset the funders array
        funders = new address[](0);
        
        //// Withdraw funds
        //// 3 ways of sending a transaction: transfer, send, call (recommended in most cases)

        /// transfer
        // reverts and throws an error if the gas used is more than 2300 gas
        // msg.sender type is address
        // payable msg.sender type is payable address
        payable (msg.sender).transfer(address(this).balance);

        /// send
        // returns a boolean of weather the transaction was successful or not, it does not revert, it is capped to 2300 gas
        // therefore if we want the transaction to revert if it is not successful we must explicitely require the returned value to be true
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Send failed");

        /// call 
        // is not capped. It returns 2 variables, the first one is a boolean indicating if the call was successfull or not, the second one is any data returned by the call function
        // For dynamic arrays like bytes, when you're dealing with function return values or temporary variables within functions, they are typically allocated in memory to save on gas costs.
        // Anyway since we don't need to save the returned data, we can simply remove it and leave a comma.
        // From (bool callSuccess, bytes memory dataReturned) = payable(msg.sender).call{value: address(this).balance}("");
        // To (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        // Also with call function we must specify the transaction to revert in case it is not successful
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

}