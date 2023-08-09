// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Owned {
    address public contractOwner;

    constructor() {
        contractOwner = msg.sender;
    }

    modifier onlyContractOwner() {
        require(
            msg.sender == contractOwner,
            "Only owner can call this function!"
        );
        _;
    }
}
