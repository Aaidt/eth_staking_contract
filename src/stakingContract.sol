// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract stakingContract {
    mapping(address => uint256) stakedAmt;
    mapping(address => uint) unclaimedRewards;
    mapping(address => uint) lastUpdatedTime;

    uint256 public totalstaked;
    address public implementation;

    event Staked(address indexed _owner, uint256 _amount);
    event Unstaked(address indexed _owner, uint256 _amount);

    function setImplementation(address _implementation) public {
        implementation = _implementation;
    }

    function stake() public payable {
        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature("stake()")
        );
        if (!success) {
            revert();
        }
    }

    function unstake(uint256 _amount) public {
        (bool success, ) = implementation.delegatecall(
            abi.encodeWithSignature("unstake(uint256)", _amount)
        );
        if (!success) {
            revert();
        }
    }

    fallback() external {
        (bool success, ) = implementation.delegatecall(msg.data);
        require(success, "Delegation failed.");
    }

    function getRewards(address _address) public view returns (uint) {
        uint currentRewards = unclaimedRewards[_address];
        uint updateTime = lastUpdatedTime[_address];
        uint newReward = (block.timestamp - updateTime) * balanceOf(_address);
        return currentRewards + newReward;
    }

    function claimRewards() public {
        uint currentRewards = unclaimedRewards[msg.sender];
        uint updateTime = lastUpdatedTime[msg.sender];
        uint newReward = (block.timestamp - updateTime) * balanceOf(msg.sender);

        payable(msg.sender).transfer(newReward + unclaimedRewards[msg.sender]);

        unclaimedRewards[msg.sender] = 0;
        lastUpdatedTime[msg.sender] = block.timestamp;
    }

    function balanceOf(address _address) public view returns (uint) {
        return stakedAmt[_address];
    }
}

contract implementationV1 {
    mapping(address => uint256) stakedAmt;
    mapping(address => uint) unclaimedRewards;
    mapping(address => uint) lastUpdatedTime;

    uint256 public totalStaked;
    address public implementation;

    event Staked(address indexed _owner, uint256 _amount);
    event Unstaked(address indexed _owner, uint256 _amount);

    function stake() public payable {
        require(msg.value > 0, "Amt deposited should be more than 0");
        if (!lastUpdatedTime[msg.sender]) {
            lastUpdatedTime[msg.sender] = block.timestamp;
        } else {
            unclaimedRewards[msg.sender] +=
                (block.timestamp - lastUpdatedTime[msg.sender]) *
                balanceOf(msg.sender);
            lastUpdatedTime[msg.sender] = block.timestamp;
        }

        stakedAmt[msg.sender] += msg.value;
        totalStaked += msg.value;

        lastUpdatedTime[msg.sender] = block.timestamp;

        emit Staked(msg.sender, msg.value);
    }

    function unstake(uint256 _amount) public {
        require(
            _amount < stakedAmt[msg.sender],
            "Cannot withdraw more than u own"
        );

        unclaimedRewards[msg.sender] +=
            (block.timestamp - lastUpdatedTime[msg.sender]) *
            balanceOf(msg.sender);
        lastUpdatedTime[msg.sender] = block.timestamp;

        payable(msg.sender).transfer(_amount);
        stakedAmt[msg.sender] -= _amount;
        totalStaked -= _amount;

        lastUpdatedTime[msg.sender] = block.timestamp;

        emit Unstaked(msg.sender, _amount);
    }

    function balanceOf(address _address) public view returns (uint) {
        return stakedAmt[_address];
    }
}

// ----------------------- Solution ---------------------------------------------


// // SPDX-License-Identifier: Unlicense
// pragma solidity ^0.8.13;

// import "forge-std/Test.sol";

// interface IKiratToken {
//     function mint(address to, uint256 amount) external;
// }

// contract StakingWithEmissions {
//     mapping(address => uint) stakes;
//     uint public totalStake;
//     uint256 public constant REWARD_PER_SEC_PER_ETH = 1;
    
//     IKiratToken public kiratToken;


//     struct UserInfo {
//         uint256 stakedAmount;
//         uint256 rewardDebt;
//         uint256 lastUpdate;
//     }

//     mapping(address => UserInfo) public userInfo;

//     constructor(IKiratToken _token) {
//         kiratToken = _token;
//     }

//     function _updateRewards(address _user) internal {
//         UserInfo storage user = userInfo[_user];

//         if (user.lastUpdate == 0) {
//             user.lastUpdate = block.timestamp;
//             return;
//         }

//         uint256 timeDiff = block.timestamp - user.lastUpdate;
//         if (timeDiff == 0) {
//             return;
//         }

//         uint256 additionalReward = (user.stakedAmount * timeDiff * REWARD_PER_SEC_PER_ETH);

//         user.rewardDebt += additionalReward;
//         user.lastUpdate = block.timestamp;
//     }


//     function stake(uint256 _amount) external payable {
//         require(_amount > 0, "Cannot stake 0");
//         require(msg.value == _amount, "ETH amount mismatch");

//         _updateRewards(msg.sender);

//         userInfo[msg.sender].stakedAmount += _amount;
//         totalStake += _amount;
//     }

//     function unstake(uint _amount) public payable {
//        require(_amount > 0, "Cannot unstake 0");
//         UserInfo storage user = userInfo[msg.sender];
//         require(user.stakedAmount >= _amount, "Not enough staked");

//         _updateRewards(msg.sender);
//         user.stakedAmount -= _amount;
//         totalStake -= _amount;

//         payable(msg.sender).transfer(_amount);
//     }

//     function claimEmissions() public {
//         _updateRewards(msg.sender);
//         UserInfo storage user = userInfo[msg.sender];
//         kiratToken.mint(msg.sender, user.rewardDebt);
//         user.rewardDebt = 0;
//     }

//     function getRewards() public view returns (uint) {
//         uint256 timeDiff = block.timestamp - userInfo[msg.sender].lastUpdate;
//         if (timeDiff == 0) {
//             return userInfo[msg.sender].rewardDebt;
//         }

//         return (userInfo[msg.sender].stakedAmount * timeDiff * REWARD_PER_SEC_PER_ETH) + userInfo[msg.sender].rewardDebt;
//     }

// }