# Atlas Stake

Production-oriented ERC20 staking and reward distribution protocol built with Solidity and Foundry.

Atlas Stake enables users to stake ERC20 assets and earn continuously distributed rewards using an efficient reward accounting model. The project focuses on protocol correctness, security, testing discipline, and operational readiness rather than feature bloat.

---

## Overview

Atlas Stake implements a staking mechanism where participants deposit ERC20 tokens into the protocol and earn rewards over time based on their proportional share of the staking pool.

The protocol is designed to demonstrate production-grade smart contract engineering practices, including:

* Modular architecture
* Reward accounting separation
* Access control
* Emergency controls
* Reentrancy protection
* Fuzz testing
* Invariant testing
* CI/CD integration
* Deployment automation
* Monitoring considerations

---

## Features

### Staking

* ERC20 token staking
* Partial withdrawals
* Full withdrawals
* Emergency withdrawals

### Rewards

* Continuous reward emissions
* Configurable reward rate
* Independent reward claiming
* Fair reward distribution across multiple participants
* Protection against duplicate reward claims

### Administration

* Role-based access control
* Protocol pause/unpause
* Reward funding management
* Reward rate updates

### Security

* Reentrancy protection
* Access-controlled administrative operations
* Custom errors for gas-efficient reverts
* Overflow validation
* Emergency controls
* Upgrade-safe storage gap awareness

---

## Architecture

```text
src/
├── core/
│   ├── AtlasStaking.sol
│   ├── RewardAccounting.sol
│   └── Storage.sol
│
├── interfaces/
│   └── IAtlasStaking.sol
│
├── libraries/
│   ├── Errors.sol
│   └── Events.sol
│
└── mocks/
    └── MockERC20.sol
```

### AtlasStaking.sol

Primary user-facing protocol contract.

Responsibilities:

* Staking
* Withdrawals
* Reward claiming
* Administrative controls
* Token transfers
* Emergency operations

### RewardAccounting.sol

Dedicated reward calculation module.

Responsibilities:

* Reward accrual
* Pool updates
* Pending reward calculations
* Reward debt accounting

### Storage.sol

Shared protocol storage layer.

Responsibilities:

* User state
* Reward state
* Token configuration
* Upgrade-safe storage layout

---

## Reward Accounting Design

Atlas Stake uses an accumulated reward-per-share model commonly adopted by production staking systems.

Core variables:

```solidity
accRewardPerShare
rewardDebt
```

### High-Level Flow

1. Rewards accumulate over time.
2. Rewards are distributed proportionally across all staked tokens.
3. Each user maintains a reward debt snapshot.
4. Pending rewards are calculated as:

```text
(user stake × accumulated rewards per share)
− reward debt
```

This design avoids iterating through all users and scales efficiently regardless of protocol participation.

---

## Example Reward Distribution

Scenario:

```text
Reward Rate = 1 token/sec

Alice stakes 100 tokens

10 seconds pass

Bob stakes 100 tokens

10 more seconds pass
```

Rewards generated:

```text
First 10 seconds:
Alice receives 10 rewards

Next 10 seconds:
20 rewards generated

Alice owns 50%
Bob owns 50%

Alice receives 10
Bob receives 10
```

Final balances:

```text
Alice = 20 rewards
Bob = 10 rewards
```

---

## Security Considerations

### Reentrancy Protection

State-changing external functions are protected against reentrant execution.

### Access Control

Administrative actions are restricted using OpenZeppelin role management.

Protected operations include:

* Pause
* Unpause
* Reward funding
* Reward rate updates

### Emergency Controls

The protocol can be paused during abnormal conditions.

Emergency withdrawal functionality allows users to recover staked assets without relying on reward calculations.

### Reward Manipulation Resistance

The accounting model prevents:

* Duplicate reward claims
* Historical reward theft
* Late-entry reward capture
* Reward dilution attacks

### Storage Safety

The protocol includes reserved storage space to support future upgrade paths without immediate storage collision risks.

---

## Threat Model

The protocol is designed to defend against:

### Reentrancy Attacks

Mitigated using:

* ReentrancyGuard
* Checks-effects-interactions pattern

### Unauthorized Administration

Mitigated using:

* AccessControl roles

### Reward Accounting Exploits

Mitigated using:

* Reward debt tracking
* Pool-wide reward accumulation

### Duplicate Reward Claims

Mitigated using:

* Reward debt updates after harvesting

### Emergency Scenarios

Mitigated using:

* Pausable controls
* Emergency withdrawal functionality

---

## Testing Strategy

### Unit Tests

Coverage includes:

* Staking
* Withdrawals
* Reward claiming
* Emergency withdrawals
* Multi-user reward distribution
* Partial withdrawal accounting
* Access control enforcement
* Pause functionality

### Fuzz Testing

Randomized testing validates:

* Stake amounts
* Reward accrual periods
* Accounting correctness across thousands of generated inputs

### Invariant Testing

Protocol invariants are continuously verified under randomized execution paths.

### Gas Testing

Gas benchmarking is included to monitor execution costs for core protocol operations.

---

## Repository Structure

```text
.
├── abi/
├── audits/
├── monitoring/
├── script/
├── src/
├── test/
├── .github/
├── .env.example
└── README.md
```

---

## Monitoring & Operations

The repository includes operational documentation under:

```text
monitoring/
├── alerts.md
├── metrics.md
└── event-indexing.md
```

Recommended production monitoring includes:

* Reward reserve depletion
* Staking volume
* Withdrawal volume
* Emergency withdrawals
* Administrative actions

---

## Deployment

### Environment

Create a local environment file:

```bash
cp .env.example .env
```

Example:

```env
PRIVATE_KEY=
SEPOLIA_RPC_URL=
BASE_SEPOLIA_RPC_URL=
ETHERSCAN_API_KEY=

STAKING_TOKEN=
REWARD_TOKEN=

REWARD_RATE=1000000000000000000
```

### Build

```bash
forge build
```

### Test

```bash
forge test
```

### Gas Report

```bash
forge test --gas-report
```

### Deploy

```bash
forge script script/DeployAtlasStaking.s.sol \
    --rpc-url $SEPOLIA_RPC_URL \
    --broadcast
```

---

## Continuous Integration

GitHub Actions automatically executes:

* Formatting checks
* Compilation
* Test suite execution

on every push and pull request.

---

## Audits

This repository has not undergone a professional third-party security audit.

Security confidence is supported through:

* Unit testing
* Fuzz testing
* Invariant testing
* Manual review

The protocol should not be deployed with real value without a dedicated security review.

---

## Future Improvements

Potential extensions include:

* Multi-reward staking
* Lock-based staking tiers
* ERC4626 compatibility
* Governance integration
* Reward vesting
* Merkle reward distribution
* Upgradeable deployment architecture

---

## Technology Stack

* Solidity 0.8.24
* Foundry
* OpenZeppelin Contracts
* GitHub Actions

---

## License

MIT
