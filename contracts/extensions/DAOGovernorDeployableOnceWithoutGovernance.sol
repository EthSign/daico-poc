// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {DAOGovernorUpgradeable} from "../DAOGovernorUpgradeable.sol";
import {DAICODeployer} from "../proxy/DAICODeployer.sol";

contract DAOGovernorDeployableOnceWithoutGovernance is DAOGovernorUpgradeable {
    bool internal _hasDeployed;

    error Unauthorized();
    error TokenMismatch();

    function deployVaultWithoutGovernanceOnce(
        DAICODeployer deployer,
        address implementation,
        bytes calldata data
    ) external returns (address) {
        if (_hasDeployed) revert Unauthorized();
        _hasDeployed = true;
        (address _projectToken, , , , ) = abi.decode(
            data,
            (address, address, uint256, uint256, address)
        );
        if (address(token()) != _projectToken) revert TokenMismatch();
        return deployer.deployDAICOCustom(implementation, data, "ICOVault");
    }
}
