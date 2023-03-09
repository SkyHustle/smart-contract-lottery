const { assert, expect } = require("chai")
const { getNamedAccounts, deployments, ethers } = require("hardhat")
const { developmentChains, networkConfig } = require("../../helper-hardhat-config")

// only run tests on development chain
!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Lottery Unit Tests", async function () {
          let lottery, vrfCoordinatorV2Mock, lotteryEntranceFee, deployer
          const chainId = network.config.chainId

          beforeEach(async function () {
              deployer = (await getNamedAccounts()).deployer
              await deployments.fixture(["all"])
              lottery = await ethers.getContract("Lottery", deployer)
              vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock", deployer)
              lotteryEntranceFee = await lottery.getEntranceFee()
          })

          describe("constructor", async function () {
              it("initialized the lottery correcty", async function () {
                  // ideally 1 assert per "it" but we're gonna bend the rules
                  const lotteryState = await lottery.getLotteryState()
                  const lotteryInterval = await lottery.getInterval()
                  const lotteryEntranceFee = await lottery.getEntranceFee()
                  assert.equal(lotteryState.toString(), "0")
                  assert.equal(lotteryInterval.toString(), networkConfig[chainId]["interval"])
                  assert.equal(lotteryEntranceFee.toString(), networkConfig[chainId]["entranceFee"])
              })
          })

          describe("enterLottery", async function () {
              it("reverts when you don't pay enough", async function () {
                  await expect(lottery.enterLottery()).to.be.revertedWith("Lottery__NotEnoughETHEntered")
              })
              it("records players when they enter", async function () {
                  await lottery.enterLottery({ value: lotteryEntranceFee })
                  const playerFromContract = await lottery.getPlayer(0)
                  assert.equal(playerFromContract, deployer)
              })
              it("emits event on enter", async function () {
                  // .emit is a waffle chai matcher
                  await expect(lottery.enterLottery({ value: lotteryEntranceFee })).to.emit(lottery, "LotteryEnter")
              })
          })
      })
