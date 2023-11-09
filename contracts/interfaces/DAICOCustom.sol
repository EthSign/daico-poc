// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IVersionable} from "./IVersionable.sol";

interface DAICOCustom is IVersionable {
    function initialize(bytes memory data) external;

    function transferOwnership(address newOwner) external;
}
