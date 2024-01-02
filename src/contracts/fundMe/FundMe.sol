// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "priceConverter/PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

/// We are going to refactor FundMe in order to make it modular and deployable on multiple chains
// We need to pass an argument in the constructor which will set the priceFeed address (based on the chain)

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;

    address private i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
    AggregatorV3Interface private s_priceFeed;
    
    // we pass in here an argument which stands for the AggregatorV3Interface address depending on the blockchain
    // we want to deploy to
    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }
    
    // Since we have already created in the constructor a s_priceFeed we can just return it here
    function getVersion() public view returns (uint256){
        return s_priceFeed.version();
    }
    
    modifier onlyOwner {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    /// Gas Optimization
    //Function to optimize gas for reading to storage

    function evenCheaperWithdraw() public onlyOwner {
        address[] memory funders = s_funders;
        uint256 fundersLength = funders.length;

        for (uint256 fundersIndex = 0; fundersIndex < fundersLength; fundersIndex++) {
            address funder = funders[fundersIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }


    function cheaperWithdraw() public onlyOwner {
        /// 1. Read from storage s_funders.length only once. Assign it to a variable and then use it to loop
        uint256 fundersLength = s_funders.length;

        for (uint256 fundersIndex = 0; fundersIndex < fundersLength; fundersIndex++) {
            address funder = s_funders[fundersIndex]; // Here we can't optimize, we have to read from storage (Or maybe would be possible here to create a local variable?)
            s_addressToAmountFunded[funder] = 0; // Here also we have to write to storage
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    
    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    /**
     * View / Pure functions (Getters)
     */

    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

}