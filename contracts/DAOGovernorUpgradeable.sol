// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {GovernorCountingSimpleUpgradeable} from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import {GovernorVotesQuorumFractionUpgradeable} from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

contract DAOGovernorUpgradeable is
    GovernorVotesQuorumFractionUpgradeable,
    GovernorCountingSimpleUpgradeable
{
    uint256 internal _votingDelay;
    uint256 internal _votingPeriod;
    uint256 internal _proposalThreshold;

    function initialize(
        string calldata _name,
        IVotes _votingToken,
        uint256 _quorumNumeratorValue,
        uint256 _votingDelay_,
        uint256 _votingPeriod_,
        uint256 _proposalThreshold_
    ) public initializer {
        __Governor_init(_name);
        __GovernorVotes_init_unchained(_votingToken);
        __GovernorVotesQuorumFraction_init_unchained(_quorumNumeratorValue);
        _votingDelay = _votingDelay_;
        _votingPeriod = _votingPeriod_;
        _proposalThreshold = _proposalThreshold_;
    }

    function votingDelay() public view virtual override returns (uint256) {
        return _votingDelay;
    }

    function votingPeriod() public view virtual override returns (uint256) {
        return _votingPeriod;
    }

    function proposalThreshold()
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _proposalThreshold;
    }
}
