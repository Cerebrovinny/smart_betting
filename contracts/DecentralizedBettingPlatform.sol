// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedBettingPlatform {
    address public owner;
    mapping (address => uint256) public balances;
    mapping (address => bool) public hasVoted;
    uint256 public totalBets;
    uint256 public totalVotes;
    bool public isLocked; //test

    struct Bet {
        address user;
        uint256 amount;
        bool result;
    }

    Bet[] public bets;

    event NewBet(address indexed user, uint256 amount, bool indexed result);

    constructor() {
        owner = msg.sender;
        isLocked = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyUnlocked() {
        require(!isLocked, "This action cannot be performed while the contract is locked");
        _;
    }

    function placeBet(bool _result) external payable onlyUnlocked {
        require(msg.value > 0, "Bet amount must be greater than 0");
        require(balances[msg.sender] >= msg.value, "Insufficient balance");

        balances[msg.sender] -= msg.value;
        bets.push(Bet(msg.sender, msg.value, _result));
        totalBets += msg.value;

        emit NewBet(msg.sender, msg.value, _result);
    }


    function withdraw() external {
        require(balances[msg.sender] > 0, "No balance to withdraw");
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

        function distributeWinnings(bool _result) external onlyOwner onlyUnlocked {
        require(bets.length > 0, "No bets have been placed");
        uint256 winningAmount = 0;
        uint256 losingAmount = 0;

        for (uint256 i = 0; i < bets.length; i++) {
            Bet memory bet = bets[i];
            if (bet.result == _result) {
                winningAmount += bet.amount;
            } else {
                losingAmount += bet.amount;
            }
        }

        require(winningAmount > 0, "No winning bets");
        require(losingAmount > 0, "No losing bets");

        uint256 fee = (totalBets * 5) / 100;
        uint256 totalPayout = winningAmount + fee;
        uint256 payoutPerWinner = totalPayout / winningAmount;

        balances[owner] += fee; // Add this line to update the contract balance


        for (uint256 i = 0; i < bets.length; i++) {
            Bet memory bet = bets[i];
            if (bet.result == _result) {
                uint256 payout = payoutPerWinner * bet.amount;
                balances[bet.user] += payout;
            }
        }

        totalVotes = 0;
        isLocked = true;
        delete bets;
    }

    function vote(bool _result) external onlyUnlocked {
        require(!hasVoted[msg.sender], "You have already voted");
        hasVoted[msg.sender] = true;
        if (_result) {
            totalVotes++;
        } else {
            totalVotes--;
        }
    }

    function unlock() external onlyOwner {
        require(isLocked, "The contract is not locked");
        require(totalVotes > 0, "No votes have been cast");

        isLocked = false;

        // Reset all votes to false
        for (uint256 i = 0; i < bets.length; i++) {
            hasVoted[bets[i].user] = false;
        }
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
    }
}