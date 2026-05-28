// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title AtlasStake Custom Errors
/// @notice Gas-efficient custom errors used across protocol contracts
library Errors {
    error ZeroAmount();
    error InvalidAddress();
    error Unauthorized();
    error InsufficientBalance();
    error ProtocolPaused();
    error EmergencyModeActive();
    error NoRewardsAvailable();
    error RewardRateTooHigh();
    error TransferFailed();
    error InvalidRewardConfiguration();
}