// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract TokenBase is ERC20 {
    address public immutable admin;
    mapping(address => bool) public allowList;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not Admin");
        _;
    }

    modifier allowedAddress() {
        require(allowList[msg.sender], "Not Allowed Address");
        _;
    }

    function allowAddress(address addr) public onlyAdmin {
        allowList[addr] = true;
    }

    function blockAddress(address addr) public onlyAdmin {
        allowList[addr] = false;
    }

    function mint(
        address owner,
        uint ammount
    ) public allowedAddress returns (bool) {
        _mint(owner, ammount);
        return true;
    }

    function burnFrom(address account, uint256 value) public returns (bool) {
        _spendAllowance(account, _msgSender(), value);
        _burn(account, value);

        return true;
    }
}
