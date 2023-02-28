// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import { console } from "forge-std/console.sol";
import { stdStorage, StdStorage, Test } from "forge-std/Test.sol";
import { Utilities } from "../utils/Utilities.sol";

import "src/mocks/MockToken.sol";
import { Refunder } from "src/MockRefunder.sol";

contract c is Test {
    Refunder refunder;

    MockToken bnb;
    MockToken bnbLend;
    MockToken dai;
    MockToken daiLend;
    MockToken eth;
    MockToken ethLend;
    MockToken ftm;
    MockToken ftmLend;

    Utilities internal utils;


    // constants //
    uint public ZERO = 0;
    uint public decimals = 18;
    uint public initialSupply = 1_000_000;
    uint ONE_THOUSAND = 1_000 * 1E18;

    // admins //
    address payable[] internal admins;
    address internal soulDAO;
    address internal ownerAddress = msg.sender;
}