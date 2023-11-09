// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {DAICOCustom} from "../interfaces/DAICOCustom.sol";

contract DAICODeployer {
    event DAICOCustomDeployed(address instance);

    function deployDAICOCustom(
        address implementation,
        bytes memory data
    ) external returns (address instance) {
        instance = Clones.clone(implementation);
        DAICOCustom(instance).initialize(data);
        DAICOCustom(instance).transferOwnership(msg.sender);
        emit DAICOCustomDeployed(instance);
    }
}
