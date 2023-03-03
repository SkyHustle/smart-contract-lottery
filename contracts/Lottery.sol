// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

error Lottery__NotEnoughETHEntered();

contract Lottery {
    uint256 private immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() public payable {
        // storing error codes are more efficient than storing strings
        if (msg.value < i_entranceFee) {
            revert Lottery__NotEnoughETHEntered();
        }
    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}
