// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ColletralToken is ERC20 {
    constructor() ERC20("Polygon", "MATIC") {
        uint256 initialSupply = 3 * 1e6 * 1e18; // 2 million tokens with 18 decimals
        _mint(msg.sender, initialSupply);
    }
}