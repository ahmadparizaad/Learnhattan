// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract LearningToken is ERC20, Ownable, ReentrancyGuard {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 10**18; // 1M tokens
    uint256 public constant REWARD_POOL = INITIAL_SUPPLY / 2;    // 50% for rewards

    constructor() ERC20("LearningToken", "LHT") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}