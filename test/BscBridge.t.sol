// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {WETHToken} from "../src/WETHToken.sol";
import {BscBridge} from "../src/BscBridge.sol";

contract BscBridgeTest is Test {
    WETHToken public token;
    BscBridge public bridge;

    event WETHBurned(address from, uint ammount);
    event WETHMinted(address to, uint ammount);

    function setUp() public {
        token = new WETHToken();
        bridge = new BscBridge(token);
    }

    function test_cannot_pass_invalid_token_address() public {
        WETHToken _token = WETHToken(address(0));
        vm.expectRevert("WETH Token address is not valid");
        new BscBridge(_token);
    }

    function test_sets_admin() public {
        assertEq(token.admin(), address(this));
    }

    function test_sets_token_address() public {
        assertEq(address(token), address(bridge.WETH()));
    }

    function test_deposit_emits_wethBurned() public {
        address test_address = address(1);
        uint test_ammount = 100;

        token.allowAddress(address(this));
        token.mint(test_address, test_ammount);
        vm.assertEq(test_ammount, token.balanceOf(test_address));

        vm.prank(test_address);
        token.approve(address(bridge), test_ammount);

        vm.prank(test_address);
        vm.expectEmit();
        emit WETHBurned(test_address, test_ammount);
        bridge.deposit(test_ammount);
    }

    function test_onlyOwner_can_call_release() public {
        vm.prank(address(1));
        vm.expectRevert("Not Admin");
        bridge.release(address(2), 10);
    }

    function test_release_emits_wethMinted() public {
        address test_address = address(1);
        uint test_ammount = 100;

        token.allowAddress(address(bridge));
        vm.expectEmit();
        emit WETHMinted(test_address, test_ammount);
        bridge.release(test_address, test_ammount);

        vm.assertEq(test_ammount, token.balanceOf(test_address));
    }
}
