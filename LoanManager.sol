// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {InterestCalculator} from "./InterestCalculator.sol";
import {PenaltyCalculator} from "./PenaltyCalculator.sol";

contract LoanManager {
    using InterestCalculator for uint256;
    using PenaltyCalculator for uint256;

    struct Loan {
        address borrower;
        address lender;
        uint256 amount;
        uint256 interests;
        uint256 annualInterestRate;
        uint256 actualInterestRate;
        uint256 activationDate;
        uint256 repaymentDate;
        string loanStatus;
    }

    struct Balance {
        // uint256 totalBalance;
        // uint256 totalCollateral;
        // uint256 totalSupply;
        // uint256 globalLTV;
        uint256 availableCollateral;
        uint256 availableSupply;
        uint256 totalLoanAmount;

        uint256 numLoans;
        mapping (uint => Loan) loans;
    }

    mapping (address => Balance) public userBalance;

    uint constant COLLATERAL_FACTOR = 75;
    uint constant DECIMAL_PRECISION = 10000;

    function depositCollateral() public payable {
        userBalance[msg.sender].availableCollateral += msg.value;
    }

    function supplyLiquidity() public payable {
        userBalance[msg.sender].availableSupply += msg.value;
    }

    function borrow(address _lender, uint256 _amount, uint256 _repaymentTermInDays) public payable {

        require(_amount <= (userBalance[msg.sender].availableCollateral * COLLATERAL_FACTOR) / 100,  "The requested amount exceeds the collateral factor (75%).");
        require(userBalance[_lender].availableSupply >= _amount, "Not enough funds to be borrowed. Try borrow from another account.");

        uint256 activationDate = block.timestamp;
        uint256 repaymentDate = activationDate + (_repaymentTermInDays * 1 days);
        string memory loanStatus = "active";

        uint256 annualInterestRate = (InterestCalculator.convertToPercentage(InterestCalculator.calculateInterestRate(_repaymentTermInDays))) * DECIMAL_PRECISION;
        uint256 interestAmount = InterestCalculator.calculateInterestAmount(_amount, _repaymentTermInDays);
        uint256 actualInterestRate = (interestAmount * 100 * DECIMAL_PRECISION) / _amount;

        
        Loan memory loan = Loan(msg.sender, _lender, _amount, interestAmount, annualInterestRate, actualInterestRate, activationDate, repaymentDate, loanStatus);

        (bool sent, bytes memory data) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        userBalance[msg.sender].loans[userBalance[msg.sender].numLoans] = loan;
        userBalance[msg.sender].numLoans++;
        userBalance[msg.sender].totalLoanAmount += _amount;

        userBalance[msg.sender].availableCollateral -= _amount;
        userBalance[_lender].availableSupply -= _amount;

    }

    function repayLoan (uint256 _loanId) public payable {
        Loan storage loan = userBalance[msg.sender].loans[_loanId];

        uint256 daysOfDelay = (block.timestamp > loan.repaymentDate) ? (block.timestamp - loan.repaymentDate) / 86400 : 0;
        uint256 penaltyAmount = InterestCalculator.calculateInterestAmount(loan.amount, daysOfDelay);

        uint256 loanAmountPlusInterestsPlusPenalty = loan.amount + loan.interests + penaltyAmount;

        require(msg.value == loanAmountPlusInterestsPlusPenalty, "Please enter the correct amount to repay the loan.");

        userBalance[msg.sender].availableCollateral += loan.amount;
        userBalance[loan.lender].availableSupply += loanAmountPlusInterestsPlusPenalty;
        userBalance[msg.sender].totalLoanAmount -= loan.amount;
        userBalance[msg.sender].numLoans--;

        loan.repaymentDate = block.timestamp;
        loan.loanStatus = "settled";

    }

    function checkPenalty(uint256 _loanId) public view returns (uint256 daysOfDelay, uint256 annualPenaltyRate, uint256 actualPenaltyRate, uint256 penaltyAmount) {
        Loan memory loan = userBalance[msg.sender].loans[_loanId];

        daysOfDelay = (block.timestamp > loan.repaymentDate) ? (block.timestamp - loan.repaymentDate) / 86400 : 0;

        annualPenaltyRate = (PenaltyCalculator.convertToPercentage(PenaltyCalculator.calculatePenaltyRate(daysOfDelay))) * DECIMAL_PRECISION;
        penaltyAmount = InterestCalculator.calculateInterestAmount(loan.amount, daysOfDelay);
        actualPenaltyRate = (penaltyAmount * 100 * DECIMAL_PRECISION) / loan.amount;
        return(daysOfDelay, annualPenaltyRate, actualPenaltyRate, penaltyAmount);
    }

    function getLoans(address _userAddress, uint256 _loanId) public view returns(address borrower, address lender, uint256 amount, uint256 interests, uint256 annualInterestRate, uint256 actualInterestRate, uint256 activationDate, uint256 repaymentDate, uint256 daysToRepayment, string memory loanStatus) {
        Loan memory loan = userBalance[_userAddress].loans[_loanId];
        daysToRepayment = keccak256(abi.encodePacked(loan.loanStatus)) == keccak256(abi.encodePacked("active")) 
        ? (loan.repaymentDate - block.timestamp) / 86400 : 0;
        return (loan.borrower, loan.lender, loan.amount, loan.interests, loan.annualInterestRate, loan.actualInterestRate, loan.activationDate, loan.repaymentDate, daysToRepayment, loan.loanStatus); 
    }

    function cancelLoan(uint256 _loanId) public payable {
        Loan storage loan = userBalance[msg.sender].loans[_loanId];

        require(block.timestamp - loan.activationDate <= 1 days, "Loan cancellation is only possible within 1 day of activation; please repay your loan in the designated section.");
        require(msg.value == loan.amount, "Please enter the exact amount of the loan to cancel.");

        userBalance[msg.sender].availableCollateral += loan.amount;
        userBalance[loan.lender].availableSupply += loan.amount;
        userBalance[msg.sender].totalLoanAmount -= loan.amount;
        userBalance[msg.sender].numLoans--;

        loan.repaymentDate = 0;
        loan.loanStatus = "cancelled";
    }

    function withdrawCollateral() public {

    }

    function withdrawSuppliedLiquidity() public {
        
    }

    receive() external payable { 
        depositCollateral();
    }

    fallback() external payable {
        depositCollateral();
     }
}