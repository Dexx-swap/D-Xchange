const { network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments
  const { deployer } = await getNamedAccounts()

  const TokenB = await deploy("TokenB", {
    from: deployer,
    args: [],
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: network.config.blockConfirmations || 1,
  })
  log(`TokenB deployed at ${TokenB.address}`)

  if (
    !developmentChains.includes(network.name) &&
    process.env.BSCSCAN_API_KEY
  ) {
    await verify(TokenB.address)
  }
}

module.exports.tags = ["all", "TokenB"]
