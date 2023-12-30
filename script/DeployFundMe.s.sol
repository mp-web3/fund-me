// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "contracts/fundMe/FundMeV3.sol";

contract DeployFundMe is Script{
    function run() external returns (FundMe) {
        vm.startBroadcast();
        FundMe fundMe = new FundMe();
        vm.stopBroadcast();
        return fundMe;

    }
}