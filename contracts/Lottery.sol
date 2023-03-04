// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

error Lottery__NotEnoughETHEntered();
error Lottery__TransferFailed();

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

// inherit from VRFConsumerBaseV2
contract Lottery is VRFConsumerBaseV2 {
    /* State Variables */
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subId;
    uint16 private constant MINIMUM_REQUEST_CONFIRMATIONS = 3;
    uint32 private immutable i_callbackGasLimit;
    uint32 private constant NUM_WORDS = 1;

    /* Lottery Variables */
    address private s_recentWinner;

    /* Events */
    event LotteryEnter(address indexed player);
    event RequestLotteryWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    constructor(
        address vrfCoordinatorV2,
        uint256 entranceFee,
        bytes32 keyHash,
        uint64 subId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_keyHash = keyHash;
        i_subId = subId;
        i_callbackGasLimit = callbackGasLimit;
    }

    function enterLottery() public payable {
        // storing error codes are more efficient than storing strings
        if (msg.value < i_entranceFee) {
            revert Lottery__NotEnoughETHEntered();
        }
        s_players.push(payable(msg.sender));
        // Emit an event when we update s_players
        emit LotteryEnter(msg.sender);
    }

    // can only be called from outside of this contract
    function requestRandomWinner() external {
        // Request random number
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash, // gasLane max gas price willing to pay for request in wei
            i_subId, // subscription for funding requests
            MINIMUM_REQUEST_CONFIRMATIONS, // how many confirmations Chainlink node should wait before responding
            i_callbackGasLimit, // how much gas to use for the callback to this function
            NUM_WORDS
        );
        emit RequestLotteryWinner(requestId);
    }

    // overide this function we get directly from VRFConsumerBaseV2
    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;
        (bool success, ) = recentWinner.call{value: address(this).balance}(""); // send winner entire contract balance, no data
        if (!success) {
            revert Lottery__TransferFailed();
        }
        emit WinnerPicked(recentWinner);
    }

    /* Getter / View functions */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }
}
