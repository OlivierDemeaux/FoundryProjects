// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/// @title The Button
/// @author Olivier Demeaux
/// @notice A simple game where users have to press a button to keep the game
///         alive and the last person that pressed the button can claim the treasure.

contract Button {

    /// EVENTS ///
    event GameOver(address winner, uint treasure);

    /// STORAGE ///

    uint public lastBlockCalled;
    address payable public lastCaller;
    bool public gameOver;

    /// CONSTRUCTOR ///

    /// @notice Constructor requires 1 eth to be send to entice other players to play
    constructor() payable {
        require(msg.value == 1 ether, "Deploy contract with 1 ether");
        lastBlockCalled = block.number;
        lastCaller = payable(msg.sender);
    }

    /// @notice Main function of the game
    function pressButton() external payable {
        // require(tx.origin == msg.sender, "Cannot be called by a contract");
        require(msg.value == 1 ether, "Send 1eth to play, no more, no less");
        require(!gameOver);
                                                      
        // if last call was more than 3 blocks ago, the game is over, and the msg.sender is refunded
        if(lastBlockCalled + 3 < block.number) {
            gameOver = true;
            (bool success, ) = msg.sender.call{value: msg.value}("");
            require(success, "call failed");
            emit GameOver(lastCaller, address(this).balance);
        // else msg.sender become lastCaller and the block 'countdown' is reset
        } else {
            lastBlockCalled = block.number;
            lastCaller = payable(msg.sender);
        }
    }

    /// @notice Claim the contract balance as treasure if game is over
    function claimTreasure() external {
        require(gameOver, "The game is still going on");
        require(lastCaller == msg.sender, "Not yours to claim");
        (bool success, ) = lastCaller.call{value: address(this).balance}("");
        require(success, "call failed");
    }

    function checkTreasureBalance() external view returns(uint) {
        return(address(this).balance);
    }

    receive() external payable {
        revert("please use the pressButton function");
    }
}