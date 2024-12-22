// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LearningToken.sol";

contract Staking {
    struct StakeInfo {
        uint256 amount;
        uint256 timestamp;
        uint256 weight;
    }

    mapping(address => StakeInfo) public stakes;
    LearningToken public token;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    constructor(address _token) {
        token = LearningToken(_token);
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Cannot stake 0 tokens");
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed");

        StakeInfo storage userStake = stakes[msg.sender];
        userStake.amount += _amount;
        userStake.timestamp = block.timestamp;
        userStake.weight = calculateWeight(userStake.amount, userStake.timestamp);

        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external {
        StakeInfo storage userStake = stakes[msg.sender];
        require(userStake.amount >= _amount, "Insufficient staked amount");

        userStake.amount -= _amount;
        userStake.weight = calculateWeight(userStake.amount, userStake.timestamp);
        require(token.transfer(msg.sender, _amount), "Transfer failed");

        emit Unstaked(msg.sender, _amount);
    }

    function calculateWeight(uint256 _amount, uint256 _timestamp) public view returns (uint256) {
        uint256 stakingDuration = block.timestamp - _timestamp;
        return _amount * (1 + stakingDuration / 1 days);
    }

    function getStakeWeight(address _user) external view returns (uint256) {
        return stakes[_user].weight;
    }
}