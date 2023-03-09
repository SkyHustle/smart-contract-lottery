const { assert } = require("chai")
const { getNamedAccounts, deployments, ethers } = require("hardhat")
const { developmentChains, networkConfig } = require("../../helper-hardhat-config")

// only run tests on development chain
!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Lottery Unit Tests", async function () {
          let lottery, vrfCoordinatorV2Mock
          const chainId = network.config.chainId

          beforeEach(async function () {
              const { deployer } = await getNamedAccounts()
              await deployments.fixture(["all"])
              lottery = await ethers.getContract("Lottery", deployer)
              vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock", deployer)
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
      })
