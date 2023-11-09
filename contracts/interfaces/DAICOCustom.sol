// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface DAICOCustom {
    function initialize(bytes memory data) external;

    function transferOwnership(address newOwner) external;
}
