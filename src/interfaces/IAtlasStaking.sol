// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IAtlasStaking {
    function stake(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function claimRewards() external;

    function emergencyWithdraw() external;

    function pendingRewards(
        address user
    ) external view returns (uint256);
}