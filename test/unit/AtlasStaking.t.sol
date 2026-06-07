// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import { AtlasStaking }
    from "../../src/core/AtlasStaking.sol";

import { MockERC20 }
    from "../../src/mocks/MockERC20.sol";

contract AtlasStakingTest is Test {

    AtlasStaking staking;

    MockERC20 stakingToken;
    MockERC20 rewardToken;

    address alice = address(1);
    address bob = address(2);

    uint256 constant INITIAL_REWARD_RATE =
        1 ether;

    function setUp() public {

        stakingToken =
            new MockERC20(
                "Stake",
                "STK"
            );

        rewardToken =
            new MockERC20(
                "Reward",
                "RWD"
            );

        staking =
            new AtlasStaking(
                address(stakingToken),
                address(rewardToken),
                INITIAL_REWARD_RATE
            );

        stakingToken.mint(
            alice,
            1000 ether
        );

        stakingToken.mint(
            bob,
            1000 ether
        );

        rewardToken.mint(
            address(this),
            100000 ether
        );

        rewardToken.approve(
            address(staking),
            type(uint256).max
        );

        staking.fundRewards(
            100000 ether
        );
    }

    function testStake() public {

        vm.startPrank(alice);

        stakingToken.approve(
            address(staking),
            100 ether
        );

        staking.stake(
            100 ether
        );

        vm.stopPrank();

        assertEq(
            staking.totalStaked(),
            100 ether
        );
    }


    function testRewardAccrualAfterTimeWarp() public {

        vm.startPrank(alice);

        stakingToken.approve(
            address(staking),
            100 ether
        );

        staking.stake(
            100 ether
        );

        vm.stopPrank();

        vm.warp(
            block.timestamp + 100
        );

        uint256 pending =
            staking.pendingRewards(
                alice
            );

        assertEq(
            pending,
            100 ether
        );
    }

    function testClaimRewards() public {

        vm.startPrank(alice);

        stakingToken.approve(
            address(staking),
            100 ether
        );

        staking.stake(
            100 ether
        );

        vm.warp(
            block.timestamp + 100
        );

        staking.claimRewards();

        vm.stopPrank();

        assertEq(
            rewardToken.balanceOf(alice),
            100 ether
        );
    }

    function testCannotDoubleClaim() public {

        vm.startPrank(alice);

        stakingToken.approve(
            address(staking),
            100 ether
        );

        staking.stake(
            100 ether
        );

        vm.warp(
            block.timestamp + 100
        );

        staking.claimRewards();

        uint256 firstClaim =
            rewardToken.balanceOf(alice);

        staking.claimRewards();

        uint256 secondClaim =
            rewardToken.balanceOf(alice);

        vm.stopPrank();

        assertEq(
            firstClaim,
            secondClaim
        );
    }

    function testWithdraw() public {

        vm.startPrank(alice);

        stakingToken.approve(
            address(staking),
            100 ether
        );

        staking.stake(
            100 ether
        );

        staking.withdraw(
            50 ether
        );

        vm.stopPrank();

        assertEq(
            staking.totalStaked(),
            50 ether
        );
    }

    function testEmergencyWithdraw() public {

        vm.startPrank(alice);

        stakingToken.approve(
            address(staking),
            100 ether
        );

        staking.stake(
            100 ether
        );

        staking.emergencyWithdraw();

        vm.stopPrank();

        assertEq(
            staking.totalStaked(),
            0
        );
    }

    function testMultipleUsersRewardDistribution() public {
        // Alice stakes first

        vm.startPrank(alice);

        stakingToken.approve(
            address(staking),
            100 ether
        );

        staking.stake(
            100 ether
        );

        vm.stopPrank();

        // 10 seconds pass

        vm.warp(11);

        // Bob joins later

        vm.startPrank(bob);

        stakingToken.approve(
            address(staking),
            100 ether
        );

        assertEq(
            stakingToken.balanceOf(bob),
            1000 ether
        );

        assertEq(
            stakingToken.allowance(
                bob,
                address(staking)
            ),
            100 ether
        );

        staking.stake(
            100 ether
        );

        vm.stopPrank();

        // another 10 seconds

        vm.warp(21);

        uint256 aliceRewards =
            staking.pendingRewards(
                alice
            );

        uint256 bobRewards =
            staking.pendingRewards(
                bob
            );

        assertEq(
            aliceRewards,
            15 ether
        );

        assertEq(
            bobRewards,
            5 ether
        );
    }

    function testRewardDistributionAfterPartialWithdraw() public {
        // Alice stakes

        vm.startPrank(alice);

        stakingToken.approve(
            address(staking),
            100 ether
        );

        staking.stake(
            100 ether
        );

        vm.stopPrank();

        // first period

        vm.warp(11);

        // Bob joins

        vm.startPrank(bob);

        stakingToken.approve(
            address(staking),
            100 ether
        );

        staking.stake(
            100 ether
        );

        vm.stopPrank();

        // second period

        vm.warp(21);

        // Alice withdraws half

        vm.startPrank(alice);

        staking.withdraw(
            50 ether
        );

        vm.stopPrank();

        uint256 aliceBalance =
            rewardToken.balanceOf(
                alice
            );

        console.log(
            "Alice claimed",
            aliceBalance
        );

        // third period

        vm.warp(31);

        uint256 aliceRewards =
            staking.pendingRewards(
                alice
            );

        uint256 bobRewards =
            staking.pendingRewards(
                bob
            );

        console.log(
            "Alice rewards",
            aliceRewards
        );

        console.log(
            "Bob rewards",
            bobRewards
        );
    }

    function testFuzzStake(uint96 amount) public {

        vm.assume(
            amount > 0 &&
            amount <= 1000 ether
        );

        vm.startPrank(alice);

        stakingToken.approve(
            address(staking),
            amount
        );

        staking.stake(
            amount
        );

        vm.stopPrank();

        assertEq(
            staking.totalStaked(),
            amount
        );
    }


    function testFuzzRewardAccrual(uint96 amount,uint32 timePassed) public {

        vm.assume(
            amount > 0 &&
            amount <= 1000 ether
        );

        vm.assume(
            timePassed > 0 &&
            timePassed <= 365 days
        );

        vm.startPrank(alice);

        stakingToken.approve(
            address(staking),
            amount
        );

        staking.stake(
            amount
        );

        vm.stopPrank();

        vm.warp(
            block.timestamp + timePassed
        );

        uint256 rewards =
            staking.pendingRewards(
                alice
            );

        uint256 expected =
            uint256(timePassed) *
            INITIAL_REWARD_RATE;

        uint256 maxDelta =
            uint256(amount) / 1 ether + 1;

        assertApproxEqAbs(
            rewards,
            expected,
            maxDelta
        );
    }

    function testNonAdminCannotPause() public {
        vm.startPrank(alice);

        vm.expectRevert();

        staking.pause();

        vm.stopPrank();
    }

    function testNonAdminCannotChangeRewardRate() public {
        vm.startPrank(alice);

        vm.expectRevert();

        staking.setRewardRate(
            100 ether
        );

        vm.stopPrank();
    }

    function testPauseBlocksStake() public {
        staking.pause();

        vm.startPrank(alice);

        stakingToken.approve(
            address(staking),
            100 ether
        );

        vm.expectRevert();

        staking.stake(
            100 ether
        );

        vm.stopPrank();
    }

}