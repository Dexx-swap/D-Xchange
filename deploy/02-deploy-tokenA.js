const { network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments
  const { deployer } = await getNamedAccounts()

  const TokenA = await deploy("TokenA", {
    from: deployer,
    args: [],
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: network.config.blockConfirmations || 1,
  })
  log(`TokenA deployed at ${TokenA.address}`)

  if (
    !developmentChains.includes(network.name) &&
    process.env.BSCSCAN_API_KEY
  ) {
    await verify(TokenA.address)
  }
}

module.exports.tags = ["all", "TokenA"]
