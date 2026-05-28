// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title AtlasStake Events
/// @notice Indexing-friendly protocol events
library Events {
    event Staked(
        address indexed user,
        uint256 amount
    );

    event Withdrawn(
        address indexed user,
        uint256 amount
    );

    event RewardsClaimed(
        address indexed user,
        uint256 amount
    );

    event EmergencyWithdraw(
        address indexed user,
        uint256 amount
    );

    event RewardRateUpdated(
        uint256 oldRate,
        uint256 newRate
    );

    event PoolUpdated(
        uint256 lastRewardTimestamp,
        uint256 totalStaked,
        uint256 accRewardPerShare
    );

    event ProtocolPaused(address indexed admin);

    event ProtocolUnpaused(address indexed admin);
}