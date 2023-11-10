// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {DAICOCustom} from "../interfaces/DAICOCustom.sol";

contract DAICODeployer {
    event DAICOCustomDeployed(
        address deployer,
        address instance,
        address implementation,
        string module
    );

    function deployDAICOCustom(
        address implementation,
        bytes memory data,
        string calldata module
    ) external returns (address instance) {
        instance = Clones.clone(implementation);
        DAICOCustom(instance).initialize(data);
        DAICOCustom(instance).transferOwnership(msg.sender);
        emit DAICOCustomDeployed(msg.sender, instance, implementation, module);
    }
}
