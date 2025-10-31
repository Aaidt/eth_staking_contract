// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract stakingContract {
    mapping(address => uint256) stakedAmt;
    uint256 public totalstaked;
    address public implementation;

    event Staked(address indexed _owner, uint256 _amount);
    event Unstaked(address indexed _owner, uint256 _amount);

    function setImplementation(address _implementation) public {
        implementation = _implementation;
    }

    function stake() public payable {
        (bool success,) = implementation.delegatecall(abi.encodeWithSignature("stake()"));
        if (!success) {
            revert();
        }
    }

    function unstake(uint256 _amount) public {
        (bool success,) = implementation.delegatecall(abi.encodeWithSignature("unstake(uint256)", _amount));
        if (!success) {
            revert();
        }
    }

    fallback() external {
        (bool success,) = implementation.delegatecall(msg.data);
        require(success, "Delegation failed.");
    }
}

contract implementationV1 {
    mapping(address => uint256) stakedAmt;
    uint256 public totalStaked;
    address public implementation;

    event Staked(address indexed _owner, uint256 _amount);
    event Unstaked(address indexed _owner, uint256 _amount);

    function stake() public payable {
        require(msg.value > 0, "Amt deposited should be more than 0");
        stakedAmt[msg.sender] += msg.value;
        totalStaked += msg.value;

        emit Staked(msg.sender, msg.value);
    }

    function unstake(uint256 _amount) public {
        require(_amount < stakedAmt[msg.sender], "Cannot withdraw more than u own");
        payable(msg.sender).transfer(_amount);
        stakedAmt[msg.sender] -= _amount;
        totalStaked -= _amount;

        emit Unstaked(msg.sender, _amount);
    }
}
