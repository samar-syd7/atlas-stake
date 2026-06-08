// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

import {AtlasStaking} from "../src/core/AtlasStaking.sol";

contract DeployAtlasStaking is Script {
    function run() external returns (AtlasStaking) {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);

        AtlasStaking staking =
            new AtlasStaking(vm.envAddress("STAKING_TOKEN"), vm.envAddress("REWARD_TOKEN"), vm.envUint("REWARD_RATE"));

        vm.stopBroadcast();

        return staking;
    }
}
