// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDToken is ERC20 {
    constructor() ERC20("USDToken", "USDT") {
        uint256 initialSupply = 2 * 1e6 * 1e18; // 2 million tokens with 18 decimals
        _mint(msg.sender, initialSupply);
    }
}