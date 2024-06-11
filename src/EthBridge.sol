// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./ETHToken.sol";

contract EthBridge {
    address public immutable admin;
    ETHToken public ETH;

    event ETHLocked(address from, uint ammount);
    event ETHReleased(address to, uint ammount);

    constructor(ETHToken ethAddress) {
        require(
            address(ethAddress) != address(0),
            "ETH Token address is not valid"
        );

        admin = msg.sender;
        ETH = ethAddress;
    }

    fallback() external payable {}
    receive() external payable {}

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not Admin");
        _;
    }

    function deposit(uint ammount) public {
        require(
            ETH.transferFrom(msg.sender, address(this), ammount),
            "Deposit failed"
        );
        emit ETHLocked(msg.sender, ammount);
    }

    function release(address to, uint ammount) public onlyAdmin {
        require(ETH.transfer(to, ammount), "Release failed");
        emit ETHReleased(to, ammount);
    }
}
