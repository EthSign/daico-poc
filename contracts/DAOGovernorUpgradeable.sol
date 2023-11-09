// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {GovernorCountingSimpleUpgradeable} from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import {GovernorVotesQuorumFractionUpgradeable} from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {ICOVault} from "./ICOVault.sol";
import {DAICOCustom} from "./interfaces/DAICOCustom.sol";

contract DAOGovernorUpgradeable is
    DAICOCustom,
    OwnableUpgradeable,
    GovernorVotesQuorumFractionUpgradeable,
    GovernorCountingSimpleUpgradeable
{
    uint256 internal _votingDelay;
    uint256 internal _votingPeriod;
    uint256 internal _proposalThreshold;

    constructor() {
        _disableInitializers();
    }

    function initialize(bytes memory data) public virtual override initializer {
        (
            string memory _name,
            IVotes _votingToken,
            uint256 _quorumNumeratorValue,
            uint256 _votingDelay_,
            uint256 _votingPeriod_,
            uint256 _proposalThreshold_
        ) = abi.decode(
                data,
                (string, IVotes, uint256, uint256, uint256, uint256)
            );
        _votingToken.getVotes(address(0)); // To make sure the project token is ERC20Votes
        __Governor_init(_name);
        __GovernorVotes_init_unchained(_votingToken);
        __GovernorVotesQuorumFraction_init_unchained(_quorumNumeratorValue);
        __Ownable_init_unchained(msg.sender);
        _votingDelay = _votingDelay_;
        _votingPeriod = _votingPeriod_;
        _proposalThreshold = _proposalThreshold_;
    }

    // solhint-disable-next-line ordering
    function version_ethsign() external pure virtual returns (string memory) {
        return "0.0.1";
    }

    function transferOwnership(
        address newOwner
    ) public virtual override(DAICOCustom, OwnableUpgradeable) {
        OwnableUpgradeable.transferOwnership(newOwner);
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
