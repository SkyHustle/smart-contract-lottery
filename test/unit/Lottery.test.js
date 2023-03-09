const { assert } = require("chai")
const { getNamedAccounts, deployments, ethers } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")

// only run tests on development chain
!developmentChains.includes(network.name)
    ? describe.skip
    : describe("Lottery Unit Tests", async function () {
          let lottery, vrfCoordinatorV2Mock

          beforeEach(async function () {
              const { deployer } = await getNamedAccounts()
              await deployments.fixture(["all"])
              lottery = await ethers.getContract("Lottery", deployer)
              vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock", deployer)
          })

          describe("constructor", async function () {
              it("initialized the lottery correcty", async function () {
                  // ideally 1 assert per "it"
                  const lotteryState = await lottery.getLotteryState()
                  assert.equal(lotteryState, 0)
              })
          })
      })
