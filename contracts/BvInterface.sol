// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// can only inherit from other interfaces.
// cannot declare a contractor.
// cannot declare state variables.
// All declared variables must be external

interface BvInterface {
    function addFunds() external payable;

    function withdraw(uint withdrawAmount) external;
}
