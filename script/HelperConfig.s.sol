// SPDX-License-Identifier: MIT

pragma solidity >=0.8.19;

import {Script} from "forge-std/Script.sol";
import {NetworkChainId, Network} from "../utils/NetworkChainId.l.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    using NetworkChainId for Network;

    struct NetworkConfig {
        address priceFeed; //eth/usd price feed address
    }

    constructor() {
        if (block.chainid == Network.SEPOLIA.getChainId()) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == Network.MAINNET.getChainId()) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            //eth/usdc price feed address in sepolia testnet
            priceFeed: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({
            //eth/usdc price feed address in ethereum mainnet
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }
}
