// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract OrcaCoin is ERC20 {
    address public stakingContract;

    constructor(address _stakingContract) ERC20("OrcaCoin", "OCC") {
        stakingContract = _stakingContract;
    }

    modifier onlyStakingContract() {
        if (msg.sender != stakingContract) {
            revert();
        }
        _;
    }

    function mint(uint256 _amount) public onlyStakingContract {
        payable(stakingContract).transfer(_amount);
    }
}
