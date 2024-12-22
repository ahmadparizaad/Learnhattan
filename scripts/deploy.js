const { ethers } = require("hardhat");

async function main() {
  // Deploy LearningToken
  const LearningTokenModule = require('../ignition/modules/LearningToken');
  const { LearningToken } = LearningTokenModule;
  if (!LearningToken) {
    throw new Error("LearningToken is undefined. Check the LearningToken module export.");
  }

  const learningToken = await LearningToken.deploy();
  await learningToken.deployed();
  console.log("LearningToken deployed to:", learningToken.address);

  // Deploy Staking with LearningToken address
  const StakingModule = require('../ignition/modules/Staking');
  const { Staking } = StakingModule;
  if (!Staking) {
    throw new Error("Staking is undefined. Check the Staking module export.");
  }
  
  const staking = await Staking.deploy(learningToken.address);
  await staking.deployed();
  console.log("Staking deployed to:", staking.address);

  
  // Deploy QuestManager with LearningToken address
  const QuestManagerModule = require('../ignition/modules/QuestManager');
  const { QuestManager } = QuestManagerModule;
  if (!QuestManager) {
   throw new Error("QuestManager is undefined. Check the QuestManager module export.");
 }

  const questManager = await QuestManager.deploy(staking.address, learningToken.address);
  await questManager.deployed();
  console.log("QuestManager deployed to:", questManager.address);
}

// Execute the deployment script
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 