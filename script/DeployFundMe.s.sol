// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "contracts/fundMe/FundMe.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

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