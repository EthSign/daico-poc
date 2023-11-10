// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {DAICOCustom} from "../interfaces/DAICOCustom.sol";
import {ICOVaultExchangeRateDataSource} from "../interfaces/ICOVaultExchangeRateDataSource.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// solhint-disable no-unused-vars
contract SimpleICOVaultExchangeRateDataSource is
    DAICOCustom,
    ICOVaultExchangeRateDataSource,
    OwnableUpgradeable
{
    mapping(address => uint256) public override tokensPerFundingUnit;

    event ExchangeRateChanged(address asset, uint256 exchangeRate);

    constructor() {
        _disableInitializers();
    }

    // solhint-disable-next-line no-unused-var
    function initialize(bytes memory data) external initializer {
        __Ownable_init_unchained(msg.sender);
    }

    function setExchangeRate(
        address asset,
        uint256 exchangeRate
    ) external onlyOwner {
        tokensPerFundingUnit[asset] = exchangeRate;
        emit ExchangeRateChanged(asset, exchangeRate);
    }

    function version_ethsign() external pure returns (string memory) {
        return "0.0.1";
    }

    function transferOwnership(
        address newOwner
    ) public virtual override(DAICOCustom, OwnableUpgradeable) {
        OwnableUpgradeable.transferOwnership(newOwner);
    }
}
