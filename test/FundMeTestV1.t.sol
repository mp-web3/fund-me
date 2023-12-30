// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "contracts/fundMe/FundMeV3.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe();

    }

    function testMinimumDollarIsFive() public { 
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        console.logUint(fundMe.MINIMUM_USD());
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.i_owner(), address(this));
    }

    function testPriceFeedVersion() public {
        uint256 expectedVersion = 4;
        uint256 actualVersion = fundMe.getVersion();
        assertEq(actualVersion, expectedVersion);
        console.logUint(actualVersion);
    }

}