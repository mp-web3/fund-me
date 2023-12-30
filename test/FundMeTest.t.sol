// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "contracts/fundMe/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        /// Instead of creating a new instance we deploy fundMe using the DeployFundMe script. So that 
        // any time we want to change the pricefeed address we just need to do it once in DeployFundMe.
        DeployFundMe deployFundMe = new DeployFundMe();
        // Now we can create an instance of FundMe by using the DeployFundMe script --> deployFundMe.run()
        fundMe = deployFundMe.run();

    }

    function testMinimumDollarIsFive() public { 
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        console.logUint(fundMe.MINIMUM_USD());
    } 

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public {
        uint256 expectedVersion = 4;
        uint256 actualVersion = fundMe.getVersion();
        assertEq(actualVersion, expectedVersion);
    }

}