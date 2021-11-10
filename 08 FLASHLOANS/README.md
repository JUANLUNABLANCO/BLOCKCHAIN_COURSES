# How To Perform Custom Ethereum Flash Loans Using Solidity (ERC 3156 Standard)

git repository:
https://github.com/JUANLUNABLANCO/BLOCKCHAIN_COURSES/tree/master/08%20FLASHLOANS

## What will I learn?

- Connecting and using an Ethereum testnet
- What is a flash loan (ERC 3156)
- Flash loan interfaces
- Flash loan wrappers
- Using a flash loan borrower contract

## Requirements

- Any chrome-based browser that allows Chrome extensions
- Metamask browser extension
- Internet connection (for using testnets)

## Relevant resources

- OpenZepellin standard IERC20 interface
- ERC3156 Ethereum Improvement Proposal
- Kovan testnet deployed flash borrow smart contract
- Wrappers for multi-application and protocols integration

## Getting started

To get started, let us use the [Kovan Ethereum testnet][1]. Any testnet would do the job, even a local one, however, the advantage of using an already deployed testnet is that some protocols may already be deployed, while you would have to deploy everything by hand if you were to test locally. Studying on the main Ethereum blockchain is prohibitively expensive, so that is already out of question, the Kovan testnet has test versions of multiple well-known Ethereum smart contracts and is already baked in Metamask.

So to proceed, you just need to have Metamask installed, and to switch to the Kovan network:

Now, intuitively, to interact with the blockchain we are going to need gas, which is paid by the native testnet version of Ethereum. For Kovan you have a few examples, as Kovan is controlled by a few peers, some of them are allowed to distribute free tokens so that you can test code without spending real money:

https://faucet.metamask.io/
https://gitter.im/kovan-testnet/faucet
https://enjin.io/software/kovan-faucet
Once you have claimed the tokens to use as gas to deploy, you are ready to start testing.

# What is ERC 3156

ERC 3156 is motivated by giving flexibility and liquidity to its users. A flash loan is when you make multiple operations within a single transaction. Those operations can be, for example: – Taking a loan, in a protocol, using the loan taken to sell it for something else, and lend what you have taken – Transfer of debt within multiple contracts, by allowing you to take a loan on a contract “x” and sending it as collateral for another contract “y”. – Attacks, because whenever there is code it can be exploited. There have been cases of flash loans being used to exploit and destroy the liquidity of small protocols.

# Lender Interface

Flashloans are a tool that allows you to leverage your position, and increase your exposure, at the risk of being liquidated. At the core of the ERC 3156 contract, are two main interfaces, called “lender” and “receiver”.

# Lender Interface Code Explained

As we can see, the lender interface by itself is composed of three core functions, to which we will get to soon, but first, let briefly understand them:

- maxFlashLoan is the maximum amount of tokens that someone can take on a flashloan. Also, it is used to tell when a token is not support (or does not have liquidity) by returning a zero. Ideally, it reflects, at most, the maximum safe amount that can be loaned, but in some cases, it can be changed for more or less safe, in terms of having enough collateral to not be immediately liquidated.

- flashFee is optional and returns to the caller how much of a fee will be charged for the transaction, it is supposed to be paid in the token in which the loan was taken. If an operation is not allowed, either by having a huge fee or for trying to loan an unsupported token, the function must [revert][3].

- flashLoan is going to be the function that is called to, in fact, lend to the contract, and can be used in flashloans to leverage by, for example, using it to add more collateral, either to increase or decrease your leverage.

A requirement of this standard is that you pass a callback function whenever you call the flashloan.

Implementation varies, but in the end, the goal is to guarantee the loan to be executed as expected.

# Borrower interface code explained

There are a few requirements at stake for the flashloan to be successful: – You must approve the flashloan smart contract to spend your ERC20 balance. It is very common on DeFi for contracts to do that because this allows the Solidity code to programmatically send and receive tokens in your name. Since the flashloan standard is a smart contract, you need to, on the ERC20 tokens you want to use, approve manually for your flashloan contract to use your balance for you. – You must, logically, have enough balance for the contract to move in your name.

# Approving a contract to spend from an ERC20

Whenever you want a contract to be able to make transactions using a third party token, such as a flash loan smart contract doing flash loans using an ERC20 token you own, you must, on the ERC20 contract approve. Let us first take a look at how that process would work for a contract that was already deployed on the testnet, in this case, Uniswap and USDC

This can be seen on Defi, when, for instance, using Uniswap. If you did not yet approve the Solidity code to use the funds from your balance, it will require you to do so:
But that will only allow you for Uniswap to spend your ERC20 tokens. If you want to manually do it, you can head into the token smart contract page on Etherscan, and manually approve from there, so you know exactly the address of the contract that you are approving and how much.

In this example, on Kovan testnet, I am using USDC, and I want to approve the protocol Compound to mint cUSDC from my USDC Kovan testnet balance, so I head into the original token contract, where I do have a balance, and check the [USDC contract code on Etherscan][4] itself.

From there I can find that I can write directly to the country, by using metamask.

Over there we can see the “approve” function, default to all ERC20 tokens, and that it takes 2 parameters as input, “\_spender” and “amount”.

\_spender is the contract that we do want to allow to use our balance for that token. and amount is how much we want to allow them to spend in total. Each time the contract uses your balance, this number decreases.

There is a technique that allows you to “approve unlimitedly” but it is not really unlimited, it is just a very big number, the biggest number the Ethereum Virtual Machine (EVM) allows! In decimals, it is exactly: 115792089237316195423570985008687907853269984665640564039457584007913129639935

So save that, and whenever you want to approve a contract to use a specific ERC20 token indefinitely, you set the allowance to that huge number!
