// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Test, console} from "forge-std/Test.sol";
import {TokenBase} from "../src/TokenBase.sol";

contract TokenBaseTest is Test {
    string public constant name = "Token";
    string public constant symbol = "TT";
    TokenBase public token;

    function setUp() public {
        token = new TokenBase(name, symbol, address(this));
    }

    // function test_setsAdmin() public view {
    //     vm.assertEq(address(this), token.admin());
    // }

    // function test_prevent_allowAdress_if_not_admin() public {
    //     vm.prank(address(1));
    //     vm.expectRevert("Not Admin");
    //     token.allowAddress(address(1));
    // }

    function test_sender_is_owner() public {
        assertEq(address(this), token.owner());
    }

    function test_can_allowAddress() public {
        token.allowAddress(address(this));
        vm.assertTrue(token.allowList(address(this)));

        token.allowAddress(address(20));
        vm.assertTrue(token.allowList(address(20)));
    }

    function test_prevent_blockAdress_if_not_admin() public {
        vm.prank(address(1));
        vm.expectRevert();
        token.blockAddress(address(1));
    }

    function test_can_blockAddress() public {
        token.blockAddress(address(this));
        vm.assertFalse(token.allowList(address(this)));

        token.blockAddress(address(20));
        vm.assertFalse(token.allowList(address(20)));
    }

    function test_cant_mint_from_not_allowed_addresses() public {
        vm.prank(address(1));
        vm.expectRevert("Not Allowed Address");
        token.mint(address(this), 100);

        vm.prank(address(1));
        vm.expectRevert("Not Allowed Address");
        token.mint(address(1), 100);
    }

    // function test_can_mint() public {
    //     token.allowAddress(address(this));
    //     vm.assertTrue(token.mint(address(this), 100));
    // }

    // function test_can_burnFrom() public {
    //     token.allowAddress(address(this));
    //     token.mint(address(1), 100);

    //     vm.prank(address(1));
    //     token.approve(address(this), 100);

    //     vm.assertTrue(token.burnFrom(address(1), 100));
    // }
}
