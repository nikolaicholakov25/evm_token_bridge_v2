// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "forge-std/Script.sol";
import {TokenBase} from "../src/TokenBase.sol";
import {Bridge} from "../src/Bridge.sol";

contract DeployBscContracts is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address owner = 0xD3CFB45f193f6c29B7359Ca7048526F463b3a187;
        vm.startBroadcast(deployerKey);

        TokenBase token = new TokenBase("CAKE", "CAKE", owner);
        Bridge bridge = new Bridge(owner, 0.001 ether);
        vm.stopBroadcast();
    }
}
