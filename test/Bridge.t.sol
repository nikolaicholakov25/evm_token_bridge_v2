// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {Bridge} from "../src/Bridge.sol";
import {TokenBase} from "../src/TokenBase.sol";

contract BridgeTest is Test {
    Bridge public bridge;
    TokenBase public erc20token;

    address public user = address(1);

    event TokenLocked(address _from, address _erc20token, uint256 _ammount);
    event TokenReleased(address _to, address _erc20token, uint256 _ammount);
    event TokenBurned(address _from, address _erc20token, uint256 _ammount);
    event TokenMinted(address _to, address _erc20token, uint256 _ammount);

    function setUp() public {
        bridge = new Bridge(address(this));
        erc20token = new TokenBase("Ethereum", "ETH", address(this));
    }

    function test_can_lock() public {
        erc20token.mint(user, 100);

        vm.prank(user);
        erc20token.approve(address(bridge), 100);

        vm.expectEmit();
        emit TokenLocked(user, address(erc20token), 100);
        bridge.lock(user, address(erc20token), 100);

        vm.assertTrue(erc20token.balanceOf(address(bridge)) == 100);
    }

    function test_can_release() public {
        erc20token.mint(address(bridge), 100);

        vm.expectEmit();
        emit TokenReleased(user, address(erc20token), 100);
        bridge.release(user, address(erc20token), 100);

        vm.assertTrue(erc20token.balanceOf(user) == 100);
    }

    function test_onlyOwner_can_release() public {
        erc20token.mint(address(bridge), 100);

        vm.prank(address(2));
        vm.expectRevert();
        bridge.release(user, address(erc20token), 100);
    }

    function test_can_burn() public {
        erc20token.mint(user, 100);

        vm.prank(user);
        erc20token.approve(address(bridge), 100);

        vm.expectEmit();
        emit TokenBurned(user, address(erc20token), 100);
        bridge.burn(user, address(erc20token), 100);

        vm.assertTrue(erc20token.balanceOf(user) == 0);
    }

    function test_onlyOwner_can_mint() public {
        vm.prank(address(2));
        vm.expectRevert();
        bridge.mint(user, address(erc20token), 100);
    }

    function test_can_mint() public {
        vm.expectEmit(true, true, true, false);
        emit TokenMinted(user, bridge.tokenPairs(address(erc20token)), 100);
        bridge.mint(user, address(erc20token), 100);

        assertTrue(
            TokenBase(bridge.tokenPairs(address(erc20token))).balanceOf(user) ==
                100
        );

        bridge.mint(user, address(erc20token), 100);
        assertTrue(
            TokenBase(bridge.tokenPairs(address(erc20token))).balanceOf(user) ==
                200
        );
    }
}
