// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "contracts/fundMe/FundMe.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

/// Lesson 7 Part 9 | Refactoring II Helper Config - Solidity & Foundry Full Course
/// https://www.youtube.com/watch?v=YqnxsefqO5A&list=PL2-Nvp2Kn0FPH2xU3IbKrrkae-VVXs1vk&index=89
// In this second refactoring we want to avoid hard coding priceFeed address, and also avoid having to 
// go through Alchemy SEPOLIA RPC ENDPOINT everytime we run a test (we don't want to run out of API calls)
// We are going to deploy a Mock Contract of 

contract DeployFundMe is Script{
    function run() external returns (FundMe) {

        // Before starting to broadcast we instantiate a new HelperConfig
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        // Anything before starting broadcasting is not a real transaction

        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;

    }
}