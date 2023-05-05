// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./TokenNEW.sol";
import "./TokenUSDT.sol";

contract Staking {
    // at the start we need to also mint token_new to staking contract
    TokenNEW token_new;
    TokenUSDT token_usdt;

    struct Stake {
        uint staked_balance; //1:1 ratio token_new: token_usdt
        uint start_time; 
        bool claimed_reward;
    }

    address public owner;
    mapping(address => Stake) public stakes;
    uint public interest_rate = 20; // 20% per day

    event buyTokenEvent(address buyer, uint amount);
    event claimEvent(address claimer, uint days_staked, uint reward_amount);
    event withdrawEvent(address withdrawer, uint withdraw_amount);

    constructor(address _token_new, address _token_usdt) {
        owner = msg.sender;
        token_new = TokenNEW(_token_new);
        token_usdt = TokenUSDT(_token_usdt);
    }

    function buyToken(uint amount) public {
        require(token_usdt.balanceOf(msg.sender) >= amount, "You don't have enough balance");
        // we should first allow to spend msg.sender tokens in TokenUSDT contract (approve transaction)
        token_usdt.transferFrom(msg.sender, address(this), amount);
        stake(amount);

        emit buyTokenEvent(msg.sender, amount);    
    }
    function stake(uint amount) internal {
        require(stakes[msg.sender].staked_balance == 0, "You already staked, it is allowed only once");

        // we should grant minter role to staking contract
        stakes[msg.sender] = Stake({
                                staked_balance: amount, 
                                start_time: block.timestamp,
                                claimed_reward: false
                            });
        token_new.mint(msg.sender, amount);
    }

    function calculateReward(uint days_staked, uint _interest_rate, uint staked_balance) public pure returns(uint) {
        uint reward_amount = days_staked  * staked_balance *  _interest_rate / 100;
        return reward_amount;
    }

    function claim() public{
        require(!stakes[msg.sender].claimed_reward, "You have already claimed reward");
        uint days_staked = (block.timestamp - stakes[msg.sender].start_time) / 86400;
        uint reward_amount = calculateReward(days_staked, interest_rate, stakes[msg.sender].staked_balance);
        stakes[msg.sender].claimed_reward = true;

        token_new.transfer(msg.sender, reward_amount);
        emit claimEvent(msg.sender, days_staked, reward_amount);  
    }

    function withdraw() public{
        require(stakes[msg.sender].staked_balance > 0, "You don't have any stakes");
        uint withdraw_amount = stakes[msg.sender].staked_balance;
        stakes[msg.sender].staked_balance = 0;
        token_usdt.transfer(msg.sender, withdraw_amount);
        token_new.transferFrom(msg.sender, address(this), withdraw_amount);
        emit buyTokenEvent(msg.sender, withdraw_amount);  
    }
}