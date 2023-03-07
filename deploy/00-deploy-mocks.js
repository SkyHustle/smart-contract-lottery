import { developmentChains } from "../helper-hardhat-config"
import { ethers } from "hardhat"

const BASE_FEE = ethers.utils.parseEther("0.25") // 0.25 Link cost per request
const GAS_PRICE_LINK = 1e9 // 1,000,000,000 // calculated value based on the gas price of the chain. Link per gas

// input vars from the hardhat runtime environment
export default async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const args = [BASE_FEE, GAS_PRICE_LINK]

    if (developmentChains.includes(network.name)) {
        log("Local Network Detected, Deploying Mocks...")
        // deploy a mock vrfCoordinator
        await deploy("VRFCoordinatorV2Mock", {
            from: deployer,
            log: true,
            args: args,
        })
        log("Mocks Deployed!")
        log("------------------------------------------------")
    }
}

export const tags = ["all", "mocks"]
