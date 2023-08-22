// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Owned.sol";
import "./Logger.sol";
import "./BvInterface.sol";

//import { BBLoanToken } from "./BBLoanToken.sol";
import { BBStableToken } from "./BBStableToken.sol";

contract BossVault is Owned {
    // Loan Token
    //BBLoanToken public loanToken;

    // Stable Token
    BBStableToken public stableToken;
    
    // vault stable balance
    uint256 public stableBalance;

    // vault loan balance
    uint256 public loanBalance;

    // vault time period
    uint256 public timePeriod;

    // ETH price
    uint256 public ethPrice;

    uint256 public round;

    uint256 public interestRate;

    uint256 public rewardsPool;

    // mapping of lenders per round
    mapping(uint256 => mapping(address => uint256)) public lenders;

    // mapping of borrowers
    mapping(address => Loan) public borrowers;

    // allow borrwing
    bool public allowBorrowing;

    // allow lending
    bool public allowLending;

    bool public allowWithdraw;

    uint256 vaultThreshold;

    struct Loan {
        uint256 amountETH;
        uint256 currentETHPrice;
        uint256 amountBBST;
        uint256 interest;
        uint256 loanRound;
        uint256 loanStart;
        uint256 loanEnd;
        uint256 insetllments;
        bool loanActive;
    }
    
    constructor(
        address _stableToken,
        uint256 _timePeriod,
        uint256 _ethPrice,
        uint256 _vaultThreshold
    ) {
        //loanToken = new BBLoanToken("Bank Boss Loan Token", "BBLT");
        stableToken = BBStableToken(_stableToken);
        timePeriod = _timePeriod;
        stableBalance = 0;
        loanBalance = 0;
        ethPrice = _ethPrice;
        round = 0;
        vaultThreshold = _vaultThreshold;
    }

    function beginRound() public {
        round += 1;
        allowBorrowing = true;
        allowLending = false;
    }
    
    function depositFunds(uint256 _amount) public {
        require(allowLending, "Lending is not allowed");
        require(stableBalance + _amount <= vaultThreshold, "Vault is full");
        // transfer stable tokens from msg.sender to vault
        stableToken.transferFrom(msg.sender, address(this), _amount);
        // add stable tokens to vault balance
        stableBalance += _amount;
        // add lender to mapping
        lenders[round+1][msg.sender] += _amount;

        if (stableBalance == vaultThreshold) {
            beginRound();
        }
    }

    function withdrawFunds() public {
        uint256 amount = lenders[round][msg.sender];
        // subtract stable tokens from vault balance
        stableBalance -= amount;
        // subtract lender from mapping
        lenders[round][msg.sender] = 0;
        // transfer stable tokens from vault to msg.sender
        stableToken.transfer(msg.sender, amount * (10 ** 18));
    }

    function borrowFunds(uint256 _interest, uint256 _insetllments) public payable {
        require(borrowers[msg.sender].loanRound != round, "User already has an active loan");
        uint256 checkInterest = msg.value * ethPrice * _interest;
        require(_interest == checkInterest, "Interest rate is not correct");
        loanBalance += msg.value;
        stableToken.transferFrom(msg.sender, address(this), _interest);
        rewardsPool += _interest;
        uint256 loanAmount = msg.value * ethPrice;
        Loan memory loan = Loan({
            amountETH: msg.value,
            currentETHPrice: ethPrice,
            amountBBST: loanAmount,
            interest: _interest,
            loanRound: round,
            loanStart: block.timestamp,
            loanEnd: block.timestamp + timePeriod,
            insetllments: _insetllments,
            loanActive: true
        });
        borrowers[msg.sender] = loan;
        stableBalance -= loanAmount;
        stableToken.transferFrom(address(this), msg.sender, loanAmount);
    }

}
