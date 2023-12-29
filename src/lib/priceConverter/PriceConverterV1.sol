// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "../../interfaces/chainlink/AggregatorV3Interface.sol";

//Libraries can't have any state variable and all functions must be marked as internal
library PriceConverter {
    function getPrice() internal view returns(uint256) {
        // Sepolia ETH/USD ChainLink PriceFeed contract: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        // Price of ETH in terms of USD
        // Will return it with 8 decimals, so 
        return uint256(answer * 1e10);
    }

    function getConversionRate(uint256 ethAmount) internal view returns(uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion() internal view returns (uint256) {
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
}