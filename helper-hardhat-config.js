const networkConfig = {
  31337: {
    name: "localhost",
    //amountIn: "100000000000000000", // 0.1 ETH
    xchangePrice: ethers.utils.parseEther("0.01"),
  },
  // Price Feed Address, values can be obtained at https://docs.chain.link/docs/reference-contracts
  // Default one is ETH/USD contract on Kovan
  97: {
    name: "Bnb",
    //amountIn: "100000000000000000", // 0.1 ETH
    xchangePrice: ethers.utils.parseEther("0.01"),
  },
}

const developmentChains = ["hardhat", "localhost"]

module.exports = {
  networkConfig,
  developmentChains,
}
