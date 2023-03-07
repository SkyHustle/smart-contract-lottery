import { network, ethers } from "hardhat"
import { networkConfig, developmentChains } from "../helper-hardhat-config"

const VRF_SUB_FUND_AMOUNT = ethers.utils.parseEther(3)

export default async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts
    const chainId = network.config.chainId
    let vrfCoordinatorV2Address, subId

    if (developmentChains.includes(network.name)) {
        const vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock")
        vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address
        const transactionResponse = await vrfCoordinatorV2Mock.createSubscription()
        const transactionReceipt = await transactionResponse.wait(1)
        subId = transactionReceipt.events[0].args.subId
        // Fund the subcription, only need LINK on real network
        await vrfCoordinatorV2Mock.fundSubcription(subId, VRF_SUB_FUND_AMOUNT)
    } else {
        // goerli
        vrfCoordinatorV2Address = networkConfig[chainId]["vrfCoordinatorV2"]
        subId = networkConfig[chainId]["subId"]
    }

    const entranceFee = networkConfig[chainId]["entranceFee"]
    const keyHash = networkConfig[chainId]["keyHash"]
    const callbackGasLimit = networkConfig[chainId]["callbackGasLimit"]
    const interval = networkConfig[chainId]["interval"]

    const lottery = await deploy("Lottery", {
        from: deployer,
        args: [vrfCoordinatorV2Address, entranceFee, keyHash, subId, callbackGasLimit, interval],
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
}
