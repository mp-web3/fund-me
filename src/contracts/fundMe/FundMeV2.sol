// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {PriceConverter} from "../../lib/priceConverter/PriceConverterV1.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    /// constant keyword makes so that a variable defined at compile time never changes. By doing so MINIMUM_USD no longer takes up storage therefore reducing the gas units
    // Gas used to deploy the contract withOUT "constant" keyword: 891,079
    // Gas used to deploy the contract WITH "constant" keyword: 871,565
    // Also will save gas when the function is called by a contract (Remember view functions have gas cost when called by a contract)
    // Tipically constant variables are in CAPS
    uint256 public constant MINIMUM_USD = 50 * 1e18; // 1e18 = 1*10**18

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    /// Variables one time but outside of the line they have been declared we mark them as immutable and we append "i_" for the sake of clarity
    address public immutable i_owner;

    /// Set the d3eployer of the contract as owner.
    constructor () {
        i_owner = msg.sender;
    }
    
    /// Make so only the owner can perform certain functions.
    // We have changed the require to revert introduced by solidity v0.8.4 https://soliditylang.org/blog/2021/04/21/custom-errors/
    modifier onlyOwner () {
        // require (msg.sender == i_owner, "Caller is not the Owner"); 

        if(msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    /// funding the contract, require a minimum of 5usd equivalent in eth. Push the sender to the funders array and map the address to amount.
    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough eth. The eth amount sent should be equal or greater than the equivalent of 5$");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }
    
    /// withdraw all funds, set to 0 the value (amount) of mapped addresses and reset the funders array. Require the caller to be owner.
    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex ++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        /// call 
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    //// What happens if someone sends this contract ETH without calling the fund() function?

    /// receive()
    // If somebody accidentally sends eth without callingh the fund() function, receive() would route them to fund() function.
    // as long as NO DATA was sent along eith eth
    receive() external payable {
        fund();
    }

    /// fallback()
    // If somebody accidentally sends eth without callingh the fund() function and including DATA to the transaction,
    // fallback() would route them to fund() function.
    fallback() external payable {
        fund();
    }

}