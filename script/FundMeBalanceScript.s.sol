// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";

contract FundMeBalanceScript is Script {
    address fundMeAddress = 0x5FbDB2315678afecb367f032d93F642f64180aa3;

    function run() external view {
        uint balance = address(fundMeAddress).balance;
        console.log("Balance of FundMe contract:", balance);
    }
}
