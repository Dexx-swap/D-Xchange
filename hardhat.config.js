require("@nomiclabs/hardhat-waffle")
require("@nomiclabs/hardhat-etherscan")
require("hardhat-deploy")
require("solidity-coverage")
require("hardhat-gas-reporter")
require("dotenv").config()

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const BNB_RPC_URL = " https://rpc.ankr.com/bsc_testnet_chapel   "
process.env.BNB_RPC_URL || " https://rpc.ankr.com/bsc_testnet_chapel  "

const PRIVATE_KEY = process.env.PRIVATE_KEY
// optional

// Your API key for Etherscan, obtain one at https://etherscan.io/
const BSCSCAN_API_KEY =
  process.env.BSCSCAN_API_KEY || "3BYSTBWHTS8AIFFS3RWQXCJUFWXB9F3W6F"

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      // // If you want to do some forking, uncomment this
      // forking: {
      //   url: MAINNET_RPC_URL
      // }
      chainId: 31337,
      blockConfirmations: 1,
    },
    localhost: {
      chainId: 31337,
      blockConfirmations: 1,
    },
    Bsc: {
      url: BNB_RPC_URL,
      accounts: [PRIVATE_KEY],
      //accounts: {
      //     mnemonic: MNEMONIC,
      // },
      saveDeployments: true,
      chainId: 97,
    },
  },
  etherscan: {
    apiKey: {
      bscTestnet: BSCSCAN_API_KEY,
    },
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    outputFile: "gas-report.txt",
    noColors: true,
    coinmarketcap: process.env.COINMARKETCAP_API_KEY,
  },

  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
      1: 0, // similarly on mainnet it will take the first account as deployer. Note though that depending on how hardhat network are configured, the account 0 on one network can be different than on another
    },
    user1: {
      default: 1,
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.9",
      },
    ],
  },
  mocha: {
    timeout: 200000, // 200 seconds max for running tests
  },
}
