// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenBase is ERC20, ERC20Burnable, Ownable {
    mapping(address => bool) public allowList;

    constructor(
        string memory name,
        string memory symbol,
        address initialOwner
    ) ERC20(name, symbol) Ownable(initialOwner) {
        allowList[initialOwner] = true;
    }

    modifier allowedAddress() {
        require(allowList[msg.sender], "Not Allowed Address");
        _;
    }

    function allowAddress(address _address) public onlyOwner {
        allowList[_address] = true;
    }

    function blockAddress(address _address) public onlyOwner {
        allowList[_address] = false;
    }

    function mint(address to, uint256 amount) public allowedAddress {
        _mint(to, amount);
    }
}
