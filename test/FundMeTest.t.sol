// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "contracts/fundMe/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    /// Set an address from which we are going to exacute transactions in tests when needed
    // function makeAddr(string memory name) internal returns(address addr);
    // Creates an address derived from the provided name. A label is created for the derived address with the provided name used as the label value.
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    address constant OWNER = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

    function setUp() external {
        /// Instead of creating a new instance we deploy fundMe using the DeployFundMe script. So that 
        // any time we want to change the pricefeed address we just need to do it once in DeployFundMe.
        DeployFundMe deployFundMe = new DeployFundMe();
        // Now we can create an instance of FundMe by using the DeployFundMe script --> deployFundMe.run()
        fundMe = deployFundMe.run();
        // Give 10 ether to USER
        vm.deal(USER, STARTING_BALANCE);

    }

    function testMinimumDollarIsFive() public { 
        assertEq(fundMe.MINIMUM_USD(), 5e18); 
        console.logUint(fundMe.MINIMUM_USD());
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public {
        uint256 expectedVersion = 4;
        uint256 actualVersion = fundMe.getVersion();
        assertEq(actualVersion, expectedVersion);
    }

    // It should revert if funds sent are less than MINIMUM_USD
    function testFundFailsIfNotEnoughEth() public {
        vm.expectRevert();

        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next TX will be sent by USER
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    /// Using the modifier funded instead of writing at the beginning of the function:
    // vm.prank(USER);
    // fundMe.fund{value: SEND_VALUE}();
    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(OWNER);
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawFromMultipleFunders() public {
        //As of Solidity v0.8, you can no longer cast explicitly from address to uint256.
        // You can now use: uint256 i = uint256(uint160(msg.sender)); https://stackoverflow.com/questions/43318077/solidity-type-address-not-convertible-to-type-uint256
        // IMPORTANT: Any time we want to use numbers to generate addresses the numbers must be of type uint160;
        uint160 numberOfFunders = 10;
        // We set the starting index to 1 instead of 0 because 0 address often reverts due to sanity checks
        uint160 startingFunderIndex = 1;
        

        // We are going to use hoax (https://book.getfoundry.sh/reference/forge-std/hoax) cheatcode from Forge Standard Library to set up multiple addresses with ether
        // instead of using vm.prank and vm.deal
        for(uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assertEq(address(fundMe).balance, 0);
        assertEq(address(fundMe.getOwner()).balance, startingOwnerBalance + startingFundMeBalance);

    }
    function testCheaperWithdrawFromMultipleFunders() public {
        //As of Solidity v0.8, you can no longer cast explicitly from address to uint256.
        // You can now use: uint256 i = uint256(uint160(msg.sender)); https://stackoverflow.com/questions/43318077/solidity-type-address-not-convertible-to-type-uint256
        // IMPORTANT: Any time we want to use numbers to generate addresses the numbers must be of type uint160;
        uint160 numberOfFunders = 10;
        // We set the starting index to 1 instead of 0 because 0 address often reverts due to sanity checks
        uint160 startingFunderIndex = 1;
        

        // We are going to use hoax (https://book.getfoundry.sh/reference/forge-std/hoax) cheatcode from Forge Standard Library to set up multiple addresses with ether
        // instead of using vm.prank and vm.deal
        for(uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assertEq(address(fundMe).balance, 0);
        assertEq(address(fundMe.getOwner()).balance, startingOwnerBalance + startingFundMeBalance);

    }
    function testEvenCheaperWithdrawFromMultipleFunders() public {
        //As of Solidity v0.8, you can no longer cast explicitly from address to uint256.
        // You can now use: uint256 i = uint256(uint160(msg.sender)); https://stackoverflow.com/questions/43318077/solidity-type-address-not-convertible-to-type-uint256
        // IMPORTANT: Any time we want to use numbers to generate addresses the numbers must be of type uint160;
        uint160 numberOfFunders = 10;
        // We set the starting index to 1 instead of 0 because 0 address often reverts due to sanity checks
        uint160 startingFunderIndex = 1;
        

        // We are going to use hoax (https://book.getfoundry.sh/reference/forge-std/hoax) cheatcode from Forge Standard Library to set up multiple addresses with ether
        // instead of using vm.prank and vm.deal
        for(uint160 i = startingFunderIndex; i <= numberOfFunders; i++) {
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.evenCheaperWithdraw();
        vm.stopPrank();

        assertEq(address(fundMe).balance, 0);
        assertEq(address(fundMe.getOwner()).balance, startingOwnerBalance + startingFundMeBalance);

    }



}