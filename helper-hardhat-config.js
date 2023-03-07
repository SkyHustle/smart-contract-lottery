import { ethers } from "hardhat"

const networkConfig = {
    5: {
        name: "goerli",
        subId: "6926",
        keyHash: "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15", // 150 gwei
        // keepersUpdateInterval: "30",
        entranceFee: ethers.utils.parseEther("0.001"), // 0.001 ETH
        // callbackGasLimit: "500000", // 500,000 gas
        vrfCoordinatorV2: "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D",
    },
    31337: {
        name: "hardhat",
        entranceFee: ethers.utils.parseEther("0.001"), // 0.001 ETH
        keyHash: "12345", // Doesn't matter, since we're mocking
    },
}

const developmentChains = ["hardhat", "localhost"]

export default {
    networkConfig,
    developmentChains,
}
