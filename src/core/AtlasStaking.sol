// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {RewardAccounting} from "./RewardAccounting.sol";

import {Errors} from "../libraries/Errors.sol";

import {Events} from "../libraries/Events.sol";

contract AtlasStaking is RewardAccounting, AccessControl, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    bytes32 public constant REWARD_MANAGER_ROLE = keccak256("REWARD_MANAGER_ROLE");

    uint256 public rewardReserve;

    constructor(address stakingToken_, address rewardToken_, uint256 rewardRatePerSecond_) {
        if (stakingToken_ == address(0) || rewardToken_ == address(0)) {
            revert Errors.InvalidAddress();
        }

        stakingToken = IERC20(stakingToken_);

        rewardToken = IERC20(rewardToken_);

        rewardRatePerSecond = rewardRatePerSecond_;

        lastRewardTimestamp = block.timestamp;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _grantRole(PAUSER_ROLE, msg.sender);

        _grantRole(REWARD_MANAGER_ROLE, msg.sender);
    }

    function stake(uint256 amount) external nonReentrant whenNotPaused {
        if (amount == 0) {
            revert Errors.ZeroAmount();
        }

        _updatePool();

        UserInfo storage user = users[msg.sender];

        if (user.amount > 0) {
            _claimInternal(msg.sender);
        }

        stakingToken.safeTransferFrom(msg.sender, address(this), amount);

        uint256 newAmount = uint256(user.amount) + amount;

        if (newAmount > type(uint128).max) {
            revert Errors.AmountOverflow();
        }

        // forge-lint: disable-next-line(unsafe-typecast)
        user.amount = uint128(newAmount);

        totalStaked += amount;

        uint256 newRewardDebt = (uint256(user.amount) * accRewardPerShare) / PRECISION_FACTOR;

        if (newRewardDebt > type(uint128).max) {
            revert Errors.AmountOverflow();
        }

        // forge-lint: disable-next-line(unsafe-typecast)
        user.rewardDebt = uint128(newRewardDebt);

        emit Events.Staked(msg.sender, amount);
    }

    function _claimInternal(address account) internal {
        uint256 rewards = _harvest(account);

        if (rewards == 0) {
            return;
        }

        if (rewards > rewardReserve) {
            rewards = rewardReserve;
        }

        if (rewards == 0) {
            return;
        }

        rewardReserve -= rewards;

        rewardToken.safeTransfer(account, rewards);

        emit Events.RewardsClaimed(account, rewards);
    }

    function claimRewards() external nonReentrant whenNotPaused {
        _updatePool();

        _claimInternal(msg.sender);
    }

    function withdraw(uint256 amount) external nonReentrant whenNotPaused {
        UserInfo storage user = users[msg.sender];

        if (amount == 0) {
            revert Errors.ZeroAmount();
        }

        if (amount > user.amount) {
            revert Errors.InsufficientBalance();
        }

        _updatePool();

        _claimInternal(msg.sender);

        if (amount > type(uint128).max) {
            revert Errors.AmountOverflow();
        }

        // forge-lint: disable-next-line(unsafe-typecast)
        user.amount -= uint128(amount);

        totalStaked -= amount;

        uint256 newRewardDebt = (uint256(user.amount) * accRewardPerShare) / PRECISION_FACTOR;

        if (newRewardDebt > type(uint128).max) {
            revert Errors.AmountOverflow();
        }

        // forge-lint: disable-next-line(unsafe-typecast)
        user.rewardDebt = uint128(newRewardDebt);

        stakingToken.safeTransfer(msg.sender, amount);

        emit Events.Withdrawn(msg.sender, amount);
    }

    function emergencyWithdraw() external nonReentrant {
        UserInfo storage user = users[msg.sender];

        uint256 amount = uint256(user.amount);

        if (amount == 0) {
            revert Errors.ZeroAmount();
        }

        totalStaked -= amount;

        user.amount = 0;
        user.rewardDebt = 0;

        stakingToken.safeTransfer(msg.sender, amount);

        emit Events.EmergencyWithdraw(msg.sender, amount);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();

        emit Events.ProtocolPaused(msg.sender);
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();

        emit Events.ProtocolUnpaused(msg.sender);
    }

    function setRewardRate(uint256 newRate) external onlyRole(REWARD_MANAGER_ROLE) {
        _updatePool();

        uint256 oldRate = rewardRatePerSecond;

        if (newRate > 1e24) {
            revert Errors.RewardRateTooHigh();
        }

        rewardRatePerSecond = newRate;

        emit Events.RewardRateUpdated(oldRate, newRate);
    }

    function fundRewards(uint256 amount) external onlyRole(REWARD_MANAGER_ROLE) {
        if (amount == 0) {
            revert Errors.ZeroAmount();
        }

        rewardToken.safeTransferFrom(msg.sender, address(this), amount);

        emit Events.RewardsFunded(msg.sender, amount);

        rewardReserve += amount;
    }
}
