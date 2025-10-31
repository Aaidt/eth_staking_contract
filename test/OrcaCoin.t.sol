// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {OrcaCoin} from "../src/OrcaCoin.sol";

contract OrcaTest is Test {
    OrcaCoin orc;

    function setUp() public {
        orc = new OrcaCoin(address(this));
    }

    function testInitialSupply() public{
        assert(orc.totalSupply() == 0);
    }
}
