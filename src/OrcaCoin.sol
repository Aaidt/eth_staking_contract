// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract OrcaCoin is ERC20 {
    address public stakingContract;
    address owner;

    constructor(address _stakingContract) ERC20("OrcaCoin", "OCC") {
        stakingContract = _stakingContract;
        owner = msg.sender;
    }

    function mint(uint256 _amount) public {
        require(msg.sender == stakingContract); 
        payable(stakingContract).transfer(_amount);
    }
     
    function updateStakingContract(address _stakingContract) public {
        require(msg.sender == owner);
        stakingContract = _stakingContract;
    }
}
