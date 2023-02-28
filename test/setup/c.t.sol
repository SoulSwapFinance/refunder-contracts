// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import { console } from "forge-std/console.sol";
import { stdStorage, StdStorage, Test } from "forge-std/Test.sol";
import { Utilities } from "../utils/Utilities.sol";

import "src/mocks/MockToken.sol";
import "src/Refunder.sol";

contract c is Test {
    Refunder refunder;
    MockToken bnb;
    MockToken dai;
    MockToken eth;
    MockToken wftm;

    Utilities internal utils;

    // constants //
    uint public decimals = 18;

    // admins //
    address payable[] internal admins;
    address internal soulDAO;
    address internal ownerAddress = msg.sender;
}