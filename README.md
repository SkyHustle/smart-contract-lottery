# Lottery 🎲
> Smart contract lottery using [ChainLink VRF2](https://chain.link/vrf) for generating a truly random number.
> This random number is used to choose a Lottery Winner. Most testing was done on a local HardHat network and then on goerli testnet.
> For testing on goerli, you have to create a subscription at https://vrf.chain.link/goerli and register a new keeper https://automation.chain.link/goerli
> You need to get some testnet ETH and Link(>13) here https://faucets.chain.link/goerli for goerli testnet.

## 📁 Table of Contents
* [General Info](#-general-information)
* [Technologies Used](#-technologies-used)
* [Requirements For Initial Setup](#-requirements-for-initial-setup)
* [Setup](#-setup)
* [Contact](#-contact)



## 🚩 General Information
- Anyone can enter the lottery by sending at minimum 0.001 ETH to the contract
- Every 30 seconds a verrifiably random winner will be picked using randomness from Chainlink VRFv2 Coordinator

 
## 💻 Technologies Used
- Chainlink VRFv2
- Hardhat
- Ethers
- Mocha, Chai testing framework

## 👀 Requirements For Initial Setup
- Install [NodeJS](https://nodejs.org/en/), should work with any node version below 18.13.0


## 📟 Setup
### 1. 💾 Clone/Download the Repository
### 2. 📦 Install Dependencies:
```
$ git clone https://github.com/Dmitry1007/smart-contract-lottery.git
$ cd smart-contract-lottery
$ yarn install
```

### 3. 🔍  .env environment variables required to set up
Create .env file inside project folder
- You can get your ethereum or testnet API key from [Alchemy](https://www.alchemy.com) or any other Node as a service operator
- You can get your private key from your wallet (Don't share your private keys EVER), best to have a separate wallet just for testing
- ChainLink VRF Subscription can be obtained [here](https://vrf.chain.link)
- Key Hash and address of vrf coordinator can be obtained from here [here](https://docs.chain.link/vrf/v2/subscription/supported-networks#goerli-testnet)
- You can get your etherscan API -key [here](https://etherscan.io/myapikey).

```
GOERLI_RPC_API="Goerli API key"
PRIVATE_KEY="Private key of your wallet you want to deploy contracts from"
ETHERSCAN_API_KEY="Etherscan API key in order to verify your contracts"
COINMARKETCAP_API_KEY="Get a gas report file after deploying"
```

### 4. ⚠️ Run Unit tests on local HardHat network or Mega staging test on GOERLI Testnet
```
$ yarn hardhat test
```
```
$ yarn hardhat coverage
```
```
$ yarn hardhat test --network goerli
```

### 5. 🚀 Deploy to HardHat local network or GOERLI
```
$ yarn hardhat deploy
``` 
```
$ yarn hardhat deploy --network goerli
``` 

### Note:
utils/verify.js implements the verification script on Etherscan, you don't need to do anything else.


## 💬 Contact
feel free to contact me with any questions. 
