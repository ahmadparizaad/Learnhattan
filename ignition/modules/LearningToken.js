const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("LearningTokenModule", (m) => {
  const LearningToken = m.contract("LearningToken", []);

  return { LearningToken };
});
