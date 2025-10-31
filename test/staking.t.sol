//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/forge-std/src/Test.sol";
import "../src/stakingContract.sol";

contract StakingTest is Test {
    stakingContract c;

    receive() external payable {} // fallback() external payable{}

    function setUp() public {
        c = new stakingContract();
    }

    function testStake() public {
        c.stake{value: 1}();
        assert(c.totalstaked() > 0);
    }

    function testRevertStake() public {
        c.stake{value: 1}();
        assert(c.totalstaked() < 0);
    }
    function testUnstake() public {}
}

