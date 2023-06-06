const { network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments
  const { deployer } = await getNamedAccounts()
  const feeAccounts = [
    "0xa381d2ce739b74eb0b5010469656ff2f2c1739c2",
    "0x0420a0e44d395ee5dde0229c5b32059aa65d9d54",
    "0x02eaeee7ad9bcbfb440cdbacbb21e4bfafba63e3",
  ]
  const feePercentage = 25 // 0.25%
  const discountFeePercentage = 20 // 0.20%

  const Xchange = await deploy("Xchange", {
    from: deployer,
    args: [feeAccounts, feePercentage, discountFeePercentage],
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: network.config.blockConfirmations || 1,
  })
  log(`Xchange deployed at ${Xchange.address}`)

  if (
    !developmentChains.includes(network.name) &&
    process.env.BSCSCAN_API_KEY
  ) {
    await verify(Xchange.address)
  }
}

module.exports.tags = ["all", "Xchange"]

/*
const { ethers } = require("hardhat");

async function main() {
  // Deploying the SwapDex contract
  const SwapDex = await ethers.getContractFactory("SwapDex");
  const swapDex = await SwapDex.deploy("<fee_account_address>", 250, 200); // Replace with actual fee account address

  await swapDex.deployed();

  console.log("SwapDex contract deployed to:", swapDex.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
*/
