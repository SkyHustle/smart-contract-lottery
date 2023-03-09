// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

error Lottery__NotEnoughETHEntered();
error Lottery__TransferFailed();
error Lottery__NotOpen();
error Lottery__UpkeepNotNeeded(uint256 currentBalance, uint256 numberOfPlayers, uint256 lotteryState);

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

// inherit from VRFConsumerBaseV2
contract Lottery is VRFConsumerBaseV2, AutomationCompatibleInterface {
    /* Type Declaration */
    enum LotteryState {
        OPEN,
        CALCULATING
    } // same as uint256 0 = OPEN, 1 = CALCULATING // Except More gas efficient

    /* State Variables */
    uint256 private immutable i_entranceFee;
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subId;
    uint32 private immutable i_callbackGasLimit;
    uint256 private immutable i_interval;
    uint16 private constant MINIMUM_REQUEST_CONFIRMATIONS = 3; // how many confirmations Chainlink node should wait before responding
    uint32 private constant NUM_WORDS = 1;
    address payable[] private s_players;
    address private s_recentWinner;
    LotteryState private s_lotteryState;
    uint256 private s_lastTimeStamp;

    /* Events */
    event LotteryEnter(address indexed player);
    event RequestLotteryWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    constructor(
        uint256 entranceFee,
        address vrfCoordinatorV2,
        bytes32 keyHash, // gasLane max gas price willing to pay for request in wei
        uint64 subId, // subscription for funding requests
        uint32 callbackGasLimit, // how much gas to use for the callback to this function
        uint256 interval
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_keyHash = keyHash;
        i_subId = subId;
        i_callbackGasLimit = callbackGasLimit;
        i_interval = interval;
        s_lotteryState = LotteryState.OPEN;
        s_lastTimeStamp = block.timestamp;
    }

    /* Functions */
    function enterLottery() public payable {
        // storing error codes are more efficient than storing strings
        if (msg.value < i_entranceFee) {
            revert Lottery__NotEnoughETHEntered();
        }

        if (s_lotteryState != LotteryState.OPEN) {
            revert Lottery__NotOpen();
        }
        s_players.push(payable(msg.sender));
        // Emit an event when we update s_players
        emit LotteryEnter(msg.sender);
    }

    // This is the func that Chainlink Keeper nodes call
    // they look for the 'upkeepNeeded to return true
    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        /* All these must be true
          1. Lottery should be OPEN
          2. Time interval should have passede
          3. Lottery should have > 0 player
          4. Subscription funded with LINK
        */
        bool isOpen = (LotteryState.OPEN == s_lotteryState);
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        bool hasPlayers = (s_players.length > 0);
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = (isOpen && timePassed && hasPlayers && hasBalance);
        return (upkeepNeeded, "0x0");
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Lottery__UpkeepNotNeeded(address(this).balance, s_players.length, uint256(s_lotteryState));
        }
        // Request random number
        s_lotteryState = LotteryState.CALCULATING;
        // this emits an event
        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_keyHash,
            i_subId,
            MINIMUM_REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        // this is redundant, since we could use requestid from i_vrfCoordinator
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
        s_lotteryState = LotteryState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
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

    function getLotteryState() public view returns (LotteryState) {
        return s_lotteryState;
    }

    function getNumberOfPlayers() public view returns (uint256) {
        return s_players.length;
    }

    function getLatestTimeStamp() public view returns (uint256) {
        return s_lastTimeStamp;
    }

    function getInterval() public view returns (uint256) {
        return i_interval;
    }

    // CONSTANTS are part of the contract byte code, NOT in Storage
    function getNumWords() public pure returns (uint256) {
        return NUM_WORDS;
    }

    function getRequestConfirmations() public pure returns (uint256) {
        return MINIMUM_REQUEST_CONFIRMATIONS;
    }
}
