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

    // error LockFailed(address _from, address _erc20token, uint256 _ammount);
    // error ReleaseFailed(address _to, address _erc20token, uint256 _ammount);

    error FeeNotPaid(address _from, uint256 _paid, uint256 _required);

    function setUp() public {
        bridge = new Bridge(address(this), 0.001 ether);
        erc20token = new TokenBase("Ethereum", "ETH", address(this));
    }

    function test_fallback() public {
        address(bridge).call{value: 1 ether}("0x0");
        vm.assertEq(address(bridge).balance, 1 ether);
    }

    function test_onlyOwner_can_change_fee() public {
        vm.prank(user);
        vm.expectRevert();
        bridge.updateFee(1 ether);
    }

    function test_can_change_fee() public {
        bridge.updateFee(1 ether);
        vm.assertTrue(bridge.fee() == 1 ether);
    }

    function test_lock_requires_fee() public {
        erc20token.mint(user, 100);

        vm.prank(user);
        erc20token.approve(address(bridge), 100);

        vm.expectRevert(
            abi.encodeWithSelector(
                FeeNotPaid.selector,
                address(this),
                0,
                0.001 ether
            )
        );
        bridge.lock(address(this), address(erc20token), 100);
    }

    function test_can_lock() public {
        erc20token.mint(user, 100);

        vm.prank(user);
        erc20token.approve(address(bridge), 100);

        vm.deal(user, 1 ether);
        vm.prank(user);
        vm.expectEmit();
        emit TokenLocked(user, address(erc20token), 100);
        bridge.lock{value: 0.001 ether}(user, address(erc20token), 100);

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

    function test_burn_requires_fee() public {
        erc20token.mint(user, 100);

        vm.prank(user);
        erc20token.approve(address(bridge), 100);

        vm.prank(user);
        vm.expectRevert(
            abi.encodeWithSelector(FeeNotPaid.selector, user, 0, 0.001 ether)
        );
        bridge.burn(user, address(erc20token), 100);
    }

    function test_can_burn() public {
        erc20token.mint(user, 100);
        vm.deal(user, 1 ether);
        vm.prank(user);
        erc20token.approve(address(bridge), 100);

        vm.prank(user);
        vm.expectEmit(false, false, false, false);
        emit TokenBurned(user, address(erc20token), 100);
        bridge.burn{value: 0.001 ether}(user, address(erc20token), 100);

        assertTrue(TokenBase(erc20token).balanceOf(user) == 0);
    }

    function test_onlyOwner_can_mint() public {
        vm.prank(address(2));
        vm.expectRevert();
        bridge.mint(user, address(erc20token), 100, "PEPE", "PEPE");
    }

    function test_can_mint() public {
        vm.expectEmit(true, true, true, false);
        emit TokenMinted(
            user,
            bridge.nativeToWrappedTokens(address(erc20token)),
            100
        );
        bridge.mint(
            user,
            address(erc20token),
            100,
            erc20token.name(),
            erc20token.symbol()
        );

        assertTrue(
            TokenBase(bridge.nativeToWrappedTokens(address(erc20token)))
                .balanceOf(user) == 100
        );

        bridge.mint(
            user,
            address(erc20token),
            100,
            erc20token.name(),
            erc20token.symbol()
        );
        assertTrue(
            TokenBase(bridge.nativeToWrappedTokens(address(erc20token)))
                .balanceOf(user) == 200
        );
    }
}
