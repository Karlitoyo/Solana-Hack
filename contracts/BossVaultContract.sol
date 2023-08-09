// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Owned.sol";
import "./Logger.sol";
import "./BvInterface.sol";

contract BossVault is Owned, Logger, BvInterface {
    uint public numOfLenders;

    // map of lenders.
    mapping(address => bool) private lenders;

    //look up table mapping of lenders.
    mapping(uint => address) private lutLenders;

    modifier limitWithdraw(uint withdrawAmount) {
        require(withdrawAmount <= 1000000000000000000, "Amount too great!");
        _;
    }

    receive() external payable {}

    function emitLog() public pure override returns (bytes32) {
        return "Hello World";
    }

    // addFunds to Vault function.
    function addFunds() external payable override {
        address lender = msg.sender;
        // iterates through lenders and adds to list if lender has not already provided liquidity.
        if (!lenders[lender]) {
            uint index = numOfLenders++;
            lenders[lender] = true;
            lutLenders[index] = lender;
        }
    }

    function test1() external onlyContractOwner {
        // some managing that only admins have access to.
    }

    function test2() external onlyContractOwner {
        // some managing that only admins have access to.
    }

    // Withdraw function from vault.
    function withdraw(
        uint withdrawAmount
    ) external override limitWithdraw(withdrawAmount) {
        // specifiying a maximum withdraw amount.
        payable(msg.sender).transfer(withdrawAmount);
    }

    // gets lenders at index.
    function getLendersAtIndex(uint8 index) external view returns (address) {
        return lutLenders[index];
    }

    // gets all lenders in the pool.
    function getAllLenders() external view returns (address[] memory) {
        address[] memory _lenders = new address[](numOfLenders);

        for (uint i = 0; i < numOfLenders; i++) {
            _lenders[i] = lutLenders[i];
        }

        return _lenders;
    }
}
