require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-verify");
require("@nomicfoundation/hardhat-ignition-ethers");
require("dotenv/config");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
        version: "0.8.28",
        settings: {
          optimizer:{
            enabled: true,
            runs: 200,
          }
        }
      },
  networks:{
    polygonAmoy:{
      url : process.env.ALCHEMY_URL,
      accounts : [process.env.PRIVATE_KEY],
    }
  },
  ignition: {
    default: {
      modules: [
        require("./ignition/modules/LearningToken"), // Deploy LearningToken first
        require("./ignition/modules/Staking"), // Deploy Staking next
        require("./ignition/modules/QuestManager"), // Deploy QuestManager last
      ],
    },
  },
  etherscan:{
    apiKey : {
      polygonAmoy : process.env.OKLINK_API_KEY,
    },
    customChains:[
      {
        network : "polygonAmoy",
        chainId : 80002,
        urls : {
          apiURL : "https://www.oklink.com/api/explorer/v1/contract/verify/async/api/polygonAmoy",
          browserURL: "https://www.oklink.com/polygonAmoy",
        }
      }
    ]
  },
  sourcify: {
    enabled: true
  }
};
