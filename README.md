# D-Xchange Contract

This is the D-Xchange contract, a decentralized exchange contract that allows users to swap tokens using the Uniswap protocol. The contract supports swapping between ERC20 tokens and Ethereum (ETH). It also implements a fee system, where a percentage of the swapped amount is collected as a fee and distributed among multiple fee accounts.

## Features

- Swapping tokens using the Uniswap protocol
- Fee system with configurable fee percentage
- Discounted fee on the last Friday of each month
- Ability to set multiple fee accounts
- Withdrawal of tokens and ETH from the contract

## Usage

### Constructor

The contract constructor initializes the contract owner, fee account, fee percentage, and discount fee percentage. It also sets the addresses of the Uniswap Router and Factory contracts.

### Function: swapTokens

This function allows users to swap tokens. Users specify the input token, output token, and the amount of input tokens they want to swap. The function transfers the input tokens from the sender to the contract, calculates the fee based on the amount, and swaps the remaining tokens using Uniswap. The swapped tokens are sent back to the sender. However, after swapping the tokens, it proceeds to convert the collected tokens into ETH by making an additional swap from the output token (_tokenOut) to ETH using the Uniswap router.

### Function: splitFees

This function splits the fees among the fee accounts. Users specify the token and the amount to be split. The function transfers the specified amount of tokens from the sender to the contract, splits the fee among the fee accounts, and transfers the remaining amount back to the sender.

### Function: setFeeAccounts

This function allows the contract owner to set the fee accounts. The owner can specify an array of addresses to be set as fee accounts.

### Function: setFeePercentage

This function allows the contract owner to set the fee percentage. The owner can specify the new fee percentage value.

### Function: setDiscountFeePercentage

This function allows the contract owner to set the discount fee percentage. The owner can specify the new discount fee percentage value.

### Function: withdrawTokens

This function allows the contract owner to withdraw tokens from the contract. The owner can specify the token and the amount to be withdrawn.

### Function: withdrawETH

This function allows the contract owner to withdraw ETH from the contract. The owner can specify the amount of ETH to be withdrawn.

## Requirements

To use this contract, you need to have the following:

- Ethereum-compatible wallet
- Sufficient balance of tokens to be swapped
- Sufficient allowance to spend tokens from your wallet

## License

This contract is licensed under the MIT license. Please refer to the SPDX-License-Identifier in the contract for more details.

# D-Xchange Smart Contract Repository

**This is the smart comtract github repository for the blockchain architecture
for D-Xchange Web3 feel free to leave any suggestions/contributions if you can
so sit back and enjoy the code. Happy hacking 💚💜 !!**

P.S. Star ⭐ if you had fun!! 😍

# Contribution Guide📚:

-   You are allowed to make pull requests that break the rules. We just merge it ;
-   Try to keep pull requests small to minimize merge conflicts

## Getting Started 🤗:

-   Fork this repo (button on top)
-   Clone on your local machine

```
git clone https://github.com/Dexx-swap/D-Xchange.git

```

-   Navigate to project directory.

```
cd D-Xchange
```

-   Create a new branch

```markdown
git checkout -b my-new-branch
```

-   Add your contribution

```
git add .
```

-   Commit your changes.

```markdown
git commit -m "Relevant message"
```

-   Then push

```
git push origin my-new-branch
```

-   Create a new pull request from your forked repository

## Avoid Conflicts (Syncing your fork)

An easy way to avoid conflicts is to add an 'D-Xchange' for your git repo, as other PR's may be merged while you're working on your branch/fork.
