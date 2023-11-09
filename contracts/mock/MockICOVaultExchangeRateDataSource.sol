// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ICOVaultExchangeRateDataSource} from "../interfaces/ICOVaultExchangeRateDataSource.sol";

// solhint-disable no-unused-vars
contract MockICOVaultExchangeRateDataSource is ICOVaultExchangeRateDataSource {
    function tokensPerFundingUnit(
        address asset
    ) external pure returns (uint256) {
        return 1;
    }
}
