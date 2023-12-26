// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";
import "forge-std/interfaces/IERC20.sol";

interface IFundMe {
    function fund() external payable;
}

contract FundMeScript is Script {
    function run() external {
        address fundMeAddress = 0x5FbDB2315678afecb367f032d93F642f64180aa3;
        IFundMe fundMe = IFundMe(fundMeAddress);

        vm.startPrank(address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266));

        fundMe.fund{value: 2 ether}();

        uint balance = address(fundMeAddress).balance;
        console.log("Balance of FundMe contract:", balance);

    }
}