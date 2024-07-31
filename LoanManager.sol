// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LoanManager {

    struct Loan {
        address borrower;
        address lender;
        uint256 amount;
        // uint256 interestRate;
        // uint256 startDate;
        // uint256 finishDate;
        // string loanStatus;
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

    uint public constant COLLATERAL_FACTOR = 75;
    // uint BORROW_APY;

    function depositCollateral() public payable {
        userBalance[msg.sender].availableCollateral += msg.value;
    }

    function supplyLiquidity() public payable {
        userBalance[msg.sender].availableSupply += msg.value;
    }

    function borrow(address _lender, uint _amount) public {
        require(_amount <= (userBalance[msg.sender].availableCollateral * COLLATERAL_FACTOR) / 100,  "The requested amount exceeds the collateral factor (75%).");
        require(userBalance[_lender].availableSupply >= _amount, "Not enough funds to be borrowed. Try borrow from another user.");
        Loan memory loan = Loan(msg.sender, _lender, _amount);

        userBalance[msg.sender].loans[userBalance[msg.sender].numLoans] = loan;
        userBalance[msg.sender].numLoans++;
        userBalance[msg.sender].totalLoanAmount += _amount;

        userBalance[msg.sender].availableCollateral -= _amount;
        userBalance[_lender].availableSupply -= _amount;
    }

    function lend() public {
        
    }

    constructor() {
        
    }
}