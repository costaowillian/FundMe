// SPDX-License-Identifier: MIT

pragma solidity >=0.8.19;

enum Network {
    SEPOLIA,
    MAINNET
}

library NetworkChainId {
    function getChainId(Network network) internal pure returns (uint256) {
        if (network == Network.SEPOLIA) return 11155111;

        if (network == Network.MAINNET) return 1;

        return 0;
    }
}
