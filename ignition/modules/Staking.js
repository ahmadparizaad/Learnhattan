const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("StakingModule", (m) => {
    const LearningToken = m.contract("LearningToken", []); // Ensure LearningToken is deployed first
    const Staking = m.contract("Staking", [LearningToken.address]); // Pass the LearningToken address

  return { Staking };
});
