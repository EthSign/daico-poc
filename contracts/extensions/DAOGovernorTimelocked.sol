// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {DAOGovernorUpgradeable, IVotes} from "../DAOGovernorUpgradeable.sol";
import {GovernorUpgradeable, GovernorTimelockControlUpgradeable} from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorTimelockControlUpgradeable.sol";
import {TimelockControllerUpgradeable} from "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";

contract DAOGovernorTimelockedUpgradeable is
    DAOGovernorUpgradeable,
    GovernorTimelockControlUpgradeable
{
    function initialize(bytes memory data) public virtual override initializer {
        (
            string memory _name,
            IVotes _votingToken,
            uint256 _quorumNumeratorValue,
            uint256 _votingDelay_,
            uint256 _votingPeriod_,
            uint256 _proposalThreshold_,
            TimelockControllerUpgradeable _timelockController
        ) = abi.decode(
                data,
                (
                    string,
                    IVotes,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    TimelockControllerUpgradeable
                )
            );
        super.initialize(
            abi.encode(
                _name,
                _votingToken,
                _quorumNumeratorValue,
                _votingDelay_,
                _votingPeriod_,
                _proposalThreshold_
            )
        );
        __GovernorTimelockControl_init_unchained(_timelockController);
    }

    // solhint-disable-next-line ordering
    function version_ethsign() external pure override returns (string memory) {
        return "0.0.1";
    }

    function votingDelay()
        public
        view
        virtual
        override(DAOGovernorUpgradeable, GovernorUpgradeable)
        returns (uint256)
    {
        return DAOGovernorUpgradeable._votingDelay;
    }

    function votingPeriod()
        public
        view
        virtual
        override(DAOGovernorUpgradeable, GovernorUpgradeable)
        returns (uint256)
    {
        return DAOGovernorUpgradeable._votingPeriod;
    }

    function proposalThreshold()
        public
        view
        virtual
        override(DAOGovernorUpgradeable, GovernorUpgradeable)
        returns (uint256)
    {
        return DAOGovernorUpgradeable._proposalThreshold;
    }

    function state(
        uint256 proposalId
    )
        public
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (ProposalState)
    {
        return GovernorTimelockControlUpgradeable.state(proposalId);
    }

    function proposalNeedsQueuing(
        uint256 proposalId
    )
        public
        view
        virtual
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (bool)
    {
        return
            GovernorTimelockControlUpgradeable.proposalNeedsQueuing(proposalId);
    }

    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (uint48)
    {
        return
            GovernorTimelockControlUpgradeable._queueOperations(
                proposalId,
                targets,
                values,
                calldatas,
                descriptionHash
            );
    }

    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
    {
        GovernorTimelockControlUpgradeable._executeOperations(
            proposalId,
            targets,
            values,
            calldatas,
            descriptionHash
        );
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (uint256)
    {
        return
            GovernorTimelockControlUpgradeable._cancel(
                targets,
                values,
                calldatas,
                descriptionHash
            );
    }

    function _executor()
        internal
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (address)
    {
        return GovernorTimelockControlUpgradeable._executor();
    }
}
