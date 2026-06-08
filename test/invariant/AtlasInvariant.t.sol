// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "forge-std/StdInvariant.sol";

import {AtlasStaking} from "../../src/core/AtlasStaking.sol";

import {MockERC20} from "../../src/mocks/MockERC20.sol";

contract AtlasInvariant is StdInvariant, Test {
    AtlasStaking staking;

    MockERC20 stakingToken;
    MockERC20 rewardToken;

    function setUp() public {
        stakingToken = new MockERC20("Stake", "STK");

        rewardToken = new MockERC20("Reward", "RWD");

        staking = new AtlasStaking(address(stakingToken), address(rewardToken), 1 ether);

        rewardToken.mint(address(this), 100000 ether);

        rewardToken.approve(address(staking), type(uint256).max);

        staking.fundRewards(100000 ether);

        targetContract(address(staking));
    }

    function invariant_RewardReserveNeverNegative() public {
        assertGe(staking.rewardReserve(), 0);
    }

    function invariant_TotalStakedMatchesBalance() public {
        assertEq(stakingToken.balanceOf(address(staking)), staking.totalStaked());
    }
}
