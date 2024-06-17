// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./WETHToken.sol";

contract BscBridge {
    address public immutable admin;
    WETHToken public WETH;

    event WETHBurned(address from, uint ammount);
    event WETHMinted(address to, uint ammount);

    constructor(WETHToken wethAddress) {
        require(
            address(wethAddress) != address(0),
            "WETH Token address is not valid"
        );

        admin = msg.sender;
        WETH = wethAddress;
    }

    fallback() external payable {}
    receive() external payable {}

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not Admin");
        _;
    }

    function deposit(uint ammount) public {
        WETH.burnFrom(msg.sender, ammount);
        emit WETHBurned(msg.sender, ammount);
    }

    function release(address to, uint ammount) public onlyAdmin {
        WETH.mint(to, ammount);
        emit WETHMinted(to, ammount);
    }
}
