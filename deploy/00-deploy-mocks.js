import { developmentChains } from "../helper-hardhat-config"

// input vars from the hardhat runtime environment
export default async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    if (developmentChains.includes(network.name)) {
        log("Local Network Detected, Deploying Mocks...")
        // deploy a mock vrfCoordinator
    }
}
