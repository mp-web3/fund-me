// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;


import {Script} from "forge-std/Script.sol";
import {SimpleStorageV1} from "../src/contracts/simpleStorage/SimpleStorageV1.sol";

contract DeploySimpleStorage is Script {
    /// run function is used to deploy the contract
    function run() external returns (SimpleStorageV1) {
        /// vm is a special keyword in the forge-std lib.
        // Everything in between vm.startBroadcast() and vm.stopBroadcast() is what we want to actually deploy
        vm.startBroadcast();
        SimpleStorageV1 simpleStorage = new SimpleStorageV1();
        vm.stopBroadcast();
        return simpleStorage;
    }
}