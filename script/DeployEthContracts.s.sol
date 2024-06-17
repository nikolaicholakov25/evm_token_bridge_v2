// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "forge-std/Script.sol";
import {ETHToken} from "../src/ETHToken.sol";
import {EthBridge} from "../src/EthBridge.sol";

contract DeployEthContracts is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);

        ETHToken token = new ETHToken();
        EthBridge bridge = new EthBridge(token);
        vm.stopBroadcast();
    }
}
