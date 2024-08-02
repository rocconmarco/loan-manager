// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {InterestCalculator} from "./InterestCalculator.sol";

contract LoanManager {
    using InterestCalculator for uint256;

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

    function borrow(address _lender, uint256 _amount, uint256 _repaymentTermInDays) public {

        require(_amount <= (userBalance[msg.sender].availableCollateral * COLLATERAL_FACTOR) / 100,  "The requested amount exceeds the collateral factor (75%).");
        require(userBalance[_lender].availableSupply >= _amount, "Not enough funds to be borrowed. Try borrow from another account.");

        uint256 activationDate = block.timestamp;
        uint256 repaymentDate = activationDate + (_repaymentTermInDays * 1 days);
        string memory loanStatus = "active";

        uint256 annualInterestRate = (InterestCalculator.convertToPercentage(InterestCalculator.calculateInterestRate(_repaymentTermInDays))) * DECIMAL_PRECISION;
        uint256 interestAmount = InterestCalculator.calculateInterestAmount(_amount, _repaymentTermInDays);
        uint256 actualInterestRate = (interestAmount * 100 * DECIMAL_PRECISION) / _amount;

        
        Loan memory loan = Loan(msg.sender, _lender, _amount, interestAmount, annualInterestRate, actualInterestRate, activationDate, repaymentDate, loanStatus);

        userBalance[msg.sender].loans[userBalance[msg.sender].numLoans] = loan;
        userBalance[msg.sender].numLoans++;
        userBalance[msg.sender].totalLoanAmount += _amount;

        userBalance[msg.sender].availableCollateral -= _amount;
        userBalance[_lender].availableSupply -= _amount;

    }

    function getLoans(address _userAddress, uint256 _loanId) public view returns(address borrower, address lender, uint256 amount, uint256 interests, uint256 annualInterestRate, uint256 actualInterestRate, uint256 activationDate, uint256 repaymentDate, uint256 daysToRepayment, string memory loanStatus) {
        Loan memory loan = userBalance[_userAddress].loans[_loanId];
        daysToRepayment = keccak256(abi.encodePacked(loan.loanStatus)) == keccak256(abi.encodePacked("active")) 
        ? (loan.repaymentDate - block.timestamp) / 86400 : 0;
        return (loan.borrower, loan.lender, loan.amount, loan.interests, loan.annualInterestRate, loan.actualInterestRate, loan.activationDate, loan.repaymentDate, daysToRepayment, loan.loanStatus); 
    }

    function cancelLoan(address _userAddress, uint256 _loanId) public {
        Loan storage loan = userBalance[_userAddress].loans[_loanId];

        require(block.timestamp - loan.activationDate <= 1 days, "Loan cancellation is only possible within 1 day of activation; please repay your loan in the designated section.");

        userBalance[_userAddress].availableCollateral += loan.amount;
        userBalance[loan.lender].availableSupply += loan.amount;
        userBalance[_userAddress].totalLoanAmount -= loan.amount;
        userBalance[_userAddress].numLoans--;

        loan.repaymentDate = 0;
        loan.loanStatus = "cancelled";
    }
}