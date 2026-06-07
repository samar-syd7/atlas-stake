# Event Indexing Guide

Index Events

- Staked(address user,uint256 amount)
- Withdrawn(address user,uint256 amount)
- RewardClaimed(address user,uint256 amount)
- RewardFunded(uint256 amount)
- RewardRateUpdated(uint256 oldRate,uint256 newRate)
- Paused(address account)
- Unpaused(address account)

Suggested Consumers

- The Graph
- Subsquid
- Custom Indexer