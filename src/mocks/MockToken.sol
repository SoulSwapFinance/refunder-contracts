// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

// import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "src/Tokens.sol";

contract MockToken is ERC20 {
    constructor(
        string memory name,
        string memory symbol,
        uint supply
    ) ERC20(name, symbol) {
        _mint(msg.sender, supply * 1E18);
    }
}
