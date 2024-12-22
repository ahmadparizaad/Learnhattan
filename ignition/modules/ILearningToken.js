const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("ILearningTokenModule", (m) => {
  const ILearningToken = m.contract("ILearningToken", []);

  return { ILearningToken };
});
