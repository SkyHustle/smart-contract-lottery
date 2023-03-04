// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

error Lottery__NotEnoughETHEntered();

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

// inherit from VRFConsumerBaseV2
contract Lottery is VRFConsumerBaseV2 {
    /* State Variables */
    uint256 private immutable i_entranceFee;
    address payable[] private s_players;

    /* Events */
    event LotteryEnter(address indexed player);

    constructor(address vrfCoordinatorV2, uint256 entranceFee) VRFConsumerBaseV2(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
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
        // do something with it when we get it back
        // 2 tx process
    }

    // overide this function we get directly from VRFConsumerBaseV2
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {}

    /* Getter / View functions */
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getPlayer(uint256 index) public view returns (address) {
        return s_players[index];
    }
}
