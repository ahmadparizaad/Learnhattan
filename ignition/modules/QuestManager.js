    const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

    module.exports = buildModule("QuestManagerModule", (m) => {
        const LearningToken = m.contract("LearningToken", []); // Ensure LearningToken is deployed first
        const Staking = m.contract("Staking", [LearningToken.address]); // Ensure LearningToken is deployed first
        const QuestManager = m.contract("QuestManager", [Staking.address, LearningToken.address]);

    return { QuestManager };
    });
