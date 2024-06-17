// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "forge-std/Script.sol";
import {TokenBase} from "../src/TokenBase.sol";
import {Bridge} from "../src/Bridge.sol";

contract DeployBscContracts is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address owner = 0xbC4C475c7DAd4EA8253626C6F73BCeA5C096eED0;
        vm.startBroadcast(deployerKey);

        TokenBase token = new TokenBase("CAKE", "CAKE", owner);
        Bridge bridge = new Bridge(owner, 0.001 ether);
        vm.stopBroadcast();
    }
}
