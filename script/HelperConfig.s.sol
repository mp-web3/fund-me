// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on local anvil chain
// 2. Keep track of contract addresses across different chains

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "mocks/MockV3Aggregator.sol";

// We updated HelperConfig contract to "is Script" in order to use vm.startbroadcast()
// in getAnvilEthConfig and deploy a price feed mock contract
contract HelperConfig is Script{

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {

            activeNetworkConfig = getSepoliaEthConfig();

        } else if (block.chainid == 1) {

            activeNetworkConfig = getEthereumEthConfig();

        } else {

            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // Sepolia price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getEthereumEthConfig() public pure returns (NetworkConfig memory) {
        // Ethereum Mainnet price feed address
        NetworkConfig memory ethereumConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethereumConfig;
    }

    /// On Anvil local network the price feed address does not exist. So we'll have to deploy 
    /// our mocked contracts

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // If we have already deployed a mockPriceFeed we don't want to deploy a new one
        if(activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // 1. Deploy mockPriceFeed using MockV3Aggregator
        // 2. Return the mock address

        vm.startBroadcast();

        //// takes 2 arguments, _decimals and _initialAnswer
        /// _decimals: A uint8 value representing the number of decimals the mock price feed values will have. 
        // This sets the scale or precision of the data returned by the aggregator.
        /// _initialAnswer: An int256 value representing the initial price or value that the mock aggregator will return. 
        // This is the starting value for the mock data, simulating the initial price feed data from an oracle.
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);

        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});

        return anvilConfig;
    }
}