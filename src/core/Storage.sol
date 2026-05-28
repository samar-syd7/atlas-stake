// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IERC20 } from
    "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title AtlasStake Storage Layout
/// @notice Shared storage definitions for protocol contracts
abstract contract Storage {
    // =============================================================
    //                           STRUCTS
    // =============================================================

    struct UserInfo {
        uint128 amount;
        uint128 rewardDebt;
        uint64 lastStakeTimestamp;
    }

    // =============================================================
    //                      TOKEN CONFIGURATION
    // =============================================================

    IERC20 public stakingToken;
    IERC20 public rewardToken;

    // =============================================================
    //                     REWARD ACCOUNTING
    // =============================================================

    uint256 public totalStaked;

    /// @notice Rewards emitted per second
    uint256 public rewardRatePerSecond;

    /// @notice Accumulated rewards per share
    /// scaled by PRECISION_FACTOR
    uint256 public accRewardPerShare;

    uint256 public lastRewardTimestamp;

    uint256 internal constant PRECISION_FACTOR = 1e18;

    // =============================================================
    //                         USER STORAGE
    // =============================================================

    mapping(address => UserInfo)
        internal users;

    // =============================================================
    //                    STORAGE GAP (UPGRADE SAFE)
    // =============================================================

    uint256[50] private __gap;
}