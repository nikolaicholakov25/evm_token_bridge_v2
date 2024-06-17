// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {ETHToken} from "../src/ETHToken.sol";
import {EthBridge} from "../src/EthBridge.sol";

contract EthBridgeTest is Test {
    ETHToken public token;
    EthBridge public bridge;

    event ETHLocked(address from, uint ammount);
    event ETHReleased(address to, uint ammount);

    function setUp() public {
        token = new ETHToken();
        bridge = new EthBridge(token);
    }

    function test_cannot_pass_invalid_token_address() public {
        ETHToken _token = ETHToken(address(0));
        vm.expectRevert("ETH Token address is not valid");
        new EthBridge(_token);
    }

    function test_sets_admin() public {
        assertEq(token.admin(), address(this));
    }

    function test_sets_token_address() public {
        assertEq(address(token), address(bridge.ETH()));
    }

    function test_deposit_emits_ethLocked() public {
        address test_address = address(1);
        uint test_ammount = 100;

        token.allowAddress(address(this));
        token.mint(test_address, test_ammount);

        vm.prank(test_address);
        token.approve(address(bridge), test_ammount);

        vm.prank(test_address);
        vm.expectEmit();
        emit ETHLocked(test_address, test_ammount);
        bridge.deposit(test_ammount);

        vm.assertEq(0, token.balanceOf(test_address));
    }

    function test_onlyOwner_can_call_release() public {
        vm.prank(address(1));
        vm.expectRevert("Not Admin");
        bridge.release(address(2), 10);
    }

    function test_release_emits_ethReleased() public {
        address test_address = address(1);
        uint test_ammount = 100;

        token.allowAddress(address(this));
        token.mint(address(bridge), test_ammount);

        vm.expectEmit();
        emit ETHReleased(address(this), test_ammount);
        bridge.release(address(this), test_ammount);
    }
}
