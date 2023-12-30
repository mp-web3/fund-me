// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on local anvil chain
// 2. Keep track of contract addresses across different chains

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";


contract HelperConfig {
    // If we are on a local anvil chain, we depoly mocks
    // Otherwise, we grab the existing address from the live network
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {

            activeNetworkConfig = getSepoliaEthConfig();

        } else if (block.chainid == 1) {

            activeNetworkConfig = getEthereumEthConfig();

        } else {

            activeNetworkConfig = getAnvilEthConfig();
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
    function getAnvilEthConfig() public pure returns (NetworkConfig memory) {
        // price feed address
    }
}