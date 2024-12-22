// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Staking.sol";
import "./interfaces/ILearningToken.sol";

contract QuestManager {
    struct Quest {
        string description;
        uint256 rewardPool;
        uint256 votingEndTime;
        uint256 topParticipants;
        bool isActive;
        bool rewardsDistributed;
    }

    struct Solution {
        address participant;
        string githubLink;
        string websiteLink;
        uint256 voteCount;
    }

    mapping(uint256 => Quest) public quests;
    mapping(uint256 => Solution[]) public questSolutions;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    
    uint256 public questCount;
    Staking public stakingContract;
    ILearningToken public learningToken;
    
    event QuestCreated(uint256 indexed questId, string description, uint256 rewardPool);
    event SolutionSubmitted(uint256 indexed questId, address indexed participant);
    event VoteCast(uint256 indexed questId, address indexed voter, address indexed participant);
    event RewardsDistributed(uint256 indexed questId);
    event RewardPaid(uint256 indexed questId, address indexed participant, uint256 amount);

    constructor(address _stakingContract, address _learningToken) {
        stakingContract = Staking(_stakingContract);
        learningToken = ILearningToken(_learningToken);
    }

    function createQuest(
        string memory _description,
        uint256 _rewardPool,
        uint256 _votingDuration,
        uint256 _topParticipants
    ) external {
        require(_rewardPool > 0, "Reward pool must be positive");
        require(_votingDuration > 0, "Voting duration must be positive");
        require(_topParticipants > 0, "Must have at least one winner");
        require(learningToken.transferFrom(msg.sender, address(this), _rewardPool), "Failed to transfer reward pool");

        uint256 questId = questCount++;
        quests[questId] = Quest({
            description: _description,
            rewardPool: _rewardPool,
            votingEndTime: block.timestamp + _votingDuration,
            topParticipants: _topParticipants,
            isActive: true,
            rewardsDistributed: false
        });

        emit QuestCreated(questId, _description, _rewardPool);
    }

    function submitSolution(
        uint256 _questId,
        string memory _githubLink,
        string memory _websiteLink
    ) external {
        Quest storage quest = quests[_questId];
        require(quest.isActive, "Quest is not active");
        require(block.timestamp < quest.votingEndTime, "Voting period has ended");

        questSolutions[_questId].push(Solution({
            participant: msg.sender,
            githubLink: _githubLink,
            websiteLink: _websiteLink,
            voteCount: 0
        }));

        emit SolutionSubmitted(_questId, msg.sender);
    }

    function vote(uint256 _questId, uint256 _solutionIndex) external {
        Quest storage quest = quests[_questId];
        require(quest.isActive, "Quest is not active");
        require(block.timestamp < quest.votingEndTime, "Voting period has ended");
        require(!hasVoted[_questId][msg.sender], "Already voted");
        require(_solutionIndex < questSolutions[_questId].length, "Invalid solution index");

        uint256 voterWeight = stakingContract.getStakeWeight(msg.sender);
        require(voterWeight > 0, "Must have staked tokens to vote");

        Solution storage solution = questSolutions[_questId][_solutionIndex];
        solution.voteCount += voterWeight;
        hasVoted[_questId][msg.sender] = true;

        emit VoteCast(_questId, msg.sender, solution.participant);
    }

    function distributeRewards(uint256 _questId) external {
        Quest storage quest = quests[_questId];
        require(quest.isActive, "Quest is not active");
        require(block.timestamp >= quest.votingEndTime, "Voting period not ended");
        require(!quest.rewardsDistributed, "Rewards already distributed");

        Solution[] storage solutions = questSolutions[_questId];
        require(solutions.length > 0, "No solutions submitted");

        // Sort solutions by vote count (simplified bubble sort)
        for (uint i = 0; i < solutions.length - 1; i++) {
            for (uint j = 0; j < solutions.length - i - 1; j++) {
                if (solutions[j].voteCount < solutions[j + 1].voteCount) {
                    Solution memory temp = solutions[j];
                    solutions[j] = solutions[j + 1];
                    solutions[j + 1] = temp;
                }
            }
        }

        // Calculate rewards for top participants
        uint256 rewardPerWinner = quest.rewardPool / quest.topParticipants;
        uint256 winnersCount = quest.topParticipants > solutions.length ? solutions.length : quest.topParticipants;

        // Distribute rewards to top participants
        for (uint256 i = 0; i < winnersCount; i++) {
            address winner = solutions[i].participant;
            require(learningToken.transfer(winner, rewardPerWinner), "Reward transfer failed");
            emit RewardPaid(_questId, winner, rewardPerWinner);
        }

        quest.isActive = false;
        quest.rewardsDistributed = true;

        emit RewardsDistributed(_questId);
    }
}