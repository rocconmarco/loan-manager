// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library InterestCalculator {
    uint256 constant PERCENT_BASE = 10000;

    struct InterestRate {
        uint256 daysThreshold;
        uint256 annualRate;
    }

    function getInterestRates() internal pure returns (InterestRate[4] memory) {
        InterestRate[4] memory rates = [
            InterestRate(30, 500),
            InterestRate(60, 700),
            InterestRate(90, 900),
            InterestRate(365, 1200)
        ];
        return rates;
    }

    function calculateInterestRate(uint256 loanDurationInDays) internal pure returns (uint256) {
        InterestRate[4] memory interestRates = getInterestRates();
        for (uint i = 0; i < interestRates.length; i++) {
            if(loanDurationInDays <= interestRates[i].daysThreshold) {
                return interestRates[i].annualRate;
            }
        }
        return interestRates[interestRates.length - 1].annualRate;
    }

    function calculateInterestAmount(uint256 principal, uint256 loanDurationInDays) internal pure returns (uint256 interestAmount) {
        uint256 annualRate = calculateInterestRate(loanDurationInDays);
        return (principal * annualRate * loanDurationInDays) / (PERCENT_BASE * 365);
    }

    function convertToPercentage(uint256 rate) internal pure returns (uint256) {
        return rate * 100 / PERCENT_BASE;
    }

}