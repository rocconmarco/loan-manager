// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library PenaltyCalculator {
    uint256 constant PERCENT_BASE = 10000;

    struct PenaltyRate {
        uint256 daysThreshold;
        uint256 annualRate;
    }

    function getPenaltyRates() internal pure returns (PenaltyRate[4] memory) {
        PenaltyRate[4] memory rates = [
            PenaltyRate(30, 700),
            PenaltyRate(60, 1000),
            PenaltyRate(90, 1200),
            PenaltyRate(365, 2000)
        ];
        return rates;
    }

    function calculatePenaltyRate(uint256 daysOfDelay) internal pure returns (uint256) {
        PenaltyRate[4] memory penaltyRates = getPenaltyRates();
        for (uint i = 0; i < penaltyRates.length; i++) {
            if(daysOfDelay <= penaltyRates[i].daysThreshold) {
                return penaltyRates[i].annualRate;
            }
        }
        return penaltyRates[penaltyRates.length - 1].annualRate;
    }

    function calculatePenaltyAmount(uint256 principal, uint256 daysOfDelay) internal pure returns (uint256 penaltyAmount) {
        uint256 annualRate = calculatePenaltyRate(daysOfDelay);
        return (principal * annualRate * daysOfDelay) / (PERCENT_BASE * 365);
    }

    function convertToPercentage(uint256 rate) internal pure returns (uint256) {
        return rate * 100 / PERCENT_BASE;
    }
}