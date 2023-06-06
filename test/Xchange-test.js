const { assert, expect } = require("chai")
const { ethers } = require("hardhat")
const { developmentChains, networkConfig } = require("../helper-hardhat-config")

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("Xchange", function () {
      let xchange
      let owner
      let feeAccounts
      //let Amount
      let xchangePrice

      beforeEach(async function () {
        ;[owner, ...feeAccounts] = await ethers.getSigners()

        const Xchange = await ethers.getContractFactory("Xchange")
        //xchangePrice = await xchange.getxchangePrice()

        xchange = await Xchange.deploy(
          feeAccounts.map((account) => account.address),
          25,
          20
        )
        await xchange.deployed()
      })

      it("should swap tokens and distribute fees correctly", async function () {
        const TokenA = await ethers.getContractFactory("TokenA")
        const tokenA = await TokenA.deploy()
        await tokenA.deployed()

        const TokenB = await ethers.getContractFactory("TokenB")
        const tokenB = await TokenB.deploy()
        await tokenB.deployed()

        // const tokenAmount = ethers.utils.parseEther("1")
        const tokenAmount = ethers.utils.parseUnits("0.01", "ether")
        const xchangePrice =
          networkConfig[network.config.chainId]["xchangePrice"]

        assert.equal(
          xchangePrice.toString(),
          networkConfig[network.config.chainId]["xchangePrice"]
        )

        // assert.equal(xchangePrice, "0.01")
        //  assert.equal(xchangePrice.toString(), "0.01")
        const expectedPrice = ethers.utils.parseEther("0.01")
        assert.equal(xchangePrice.toString(), expectedPrice.toString())

        const tokenOwner = owner.address
        const spender = xchange.address

        await tokenA.increaseAllowance(
          xchange.address,
          ethers.utils.parseEther(xchangePrice.toString())
        )

        const tokenAllowance = await tokenA.allowance(tokenOwner, spender)
        console.log("Token Allowance:", tokenAllowance.toString())

        // if (tokenAllowance < tokenAmount) {
        //   throw new Error("Insufficient token allowance")
        // }

        // await tokenA.transfer(xchange.address, tokenAmount)

        // await tokenA.approve(xchange.address, tokenAmount)
        /* const tokenOwnerBalance = await tokenA.balanceOf(owner.address)
    if (tokenOwnerBalance.lt(tokenAmount)) {
      throw new Error("Insufficient token balance")
    }*/

        // await tokenA.transferFrom(owner.address, xchange.address, tokenAmount)
        await xchange.swapTokens(tokenA.address, tokenB.address, tokenAmount)

        const tokenABalance = await tokenA.balanceOf(xchange.address)
        expect(tokenABalance).to.equal(0)

        const tokenBBalance = await tokenB.balanceOf(xchange.address)
        expect(tokenBBalance).to.be.above(0)

        const ethBalance = await ethers.provider.getBalance(xchange.address)
        expect(ethBalance).to.be.above(0)

        const feeShare = ethBalance.div(feeAccounts.length)
        for (const account of feeAccounts) {
          const accountBalanceBefore = await ethers.provider.getBalance(
            account.address
          )
          await xchange.connect(account).splitFees()
          const accountBalanceAfter = await ethers.provider.getBalance(
            account.address
          )
          expect(accountBalanceAfter).to.equal(
            accountBalanceBefore.add(feeShare)
          )
        }
      })
    })
