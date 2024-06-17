// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "forge-std/Script.sol";
import {WETHToken} from "../src/WETHToken.sol";
import {BscBridge} from "../src/BscBridge.sol";

contract DeployBscContracts is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);

        WETHToken token = new WETHToken();
        BscBridge bridge = new BscBridge(token);
        vm.stopBroadcast();
    }
}
