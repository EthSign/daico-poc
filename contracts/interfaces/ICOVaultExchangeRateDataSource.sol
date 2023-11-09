// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface ICOVaultExchangeRateDataSource {
    // @dev Use address(0) for exchange rate with ether.
    function tokensPerFundingUnit(
        address asset
    ) external view returns (uint256);
}
