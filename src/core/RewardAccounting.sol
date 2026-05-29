// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Storage } from "./Storage.sol";

abstract contract RewardAccounting is Storage {
    function _updatePool() internal {
        // forge-lint: disable-next-line(block-timestamp)
        if (block.timestamp <= lastRewardTimestamp) {
            return;
        }

        if (totalStaked == 0) {
            lastRewardTimestamp = uint64(block.timestamp);
            return;
        }

        uint256 timeElapsed =
            block.timestamp - lastRewardTimestamp;

        uint256 rewards =
            timeElapsed * rewardRatePerSecond;

        accRewardPerShare +=
            (rewards * PRECISION_FACTOR)
            / totalStaked;

        lastRewardTimestamp = uint64(block.timestamp);
    }

    function _pendingRewards(
        address account
    )
        internal
        view
        returns (uint256)
    {
        UserInfo storage user =
            users[account];

        uint256 currentAccRewardPerShare =
            accRewardPerShare;

        // forge-lint: disable-next-line(block-timestamp)
        if (
            block.timestamp > lastRewardTimestamp
            && totalStaked > 0
        ) {
            uint256 elapsed =
                block.timestamp -
                lastRewardTimestamp;

            uint256 rewards =
                elapsed *
                rewardRatePerSecond;

            currentAccRewardPerShare +=
                (rewards * PRECISION_FACTOR)
                / totalStaked;
        }

        return (
            (uint256(user.amount)
            * currentAccRewardPerShare)
            / PRECISION_FACTOR
        ) - uint256(user.rewardDebt);
    }

    function _harvest(
        address account
    )
        internal
        returns (uint256 rewards)
    {
        _updatePool();

        rewards =
            _pendingRewards(account);

        if (rewards == 0) {
            return 0;
        }

        UserInfo storage user =
            users[account];

        uint256 newRewardDebt =
            (uint256(user.amount)
            * accRewardPerShare)
            / PRECISION_FACTOR;

        require(
            newRewardDebt <= type(uint128).max,
            "Reward debt overflow"
        );

        user.rewardDebt =
            uint128(newRewardDebt);
    }

    function pendingRewards(
        address account
    )
        public
        view
        returns (uint256)
    {
        return _pendingRewards(account);
    }
}