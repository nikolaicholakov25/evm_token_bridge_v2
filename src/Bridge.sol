// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./TokenBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";

contract Bridge is Ownable {
    mapping(address => address) public tokenPairs;

    fallback() external payable {}
    receive() external payable {}

    constructor(address _initialOwner) Ownable(_initialOwner) {}

    event TokenLocked(address _from, address _erc20token, uint256 _ammount);
    event TokenReleased(address _to, address _erc20token, uint256 _ammount);
    event TokenBurned(address _from, address _erc20token, uint256 _ammount);
    event TokenMinted(address _to, address _erc20token, uint256 _ammount);

    function lock(
        address _from,
        address _erc20token,
        uint256 _ammount
    ) external {
        require(
            TokenBase(_erc20token).transferFrom(_from, address(this), _ammount),
            "Locking failed"
        );

        emit TokenLocked(_from, _erc20token, _ammount);
    }

    function release(
        address _to,
        address _erc20token,
        uint256 _ammount
    ) external onlyOwner {
        require(
            TokenBase(_erc20token).transfer(_to, _ammount),
            "Release failed"
        );

        emit TokenReleased(_to, _erc20token, _ammount);
    }

    function burn(
        address _from,
        address _erc20token,
        uint256 _ammount
    ) external {
        TokenBase(_erc20token).burnFrom(_from, _ammount);

        emit TokenBurned(_from, _erc20token, _ammount);
    }

    function mint(
        address _to,
        address _erc20token,
        uint256 _ammount
    ) external onlyOwner {
        bool pairExist = tokenPairs[_erc20token] != address(0);

        string memory nativeName = TokenBase(_erc20token).name();
        string memory nativeSymbol = TokenBase(_erc20token).symbol();

        string memory wrappedName = string.concat("Wrapped", nativeName);
        string memory wrappedSymbol = string.concat("W", nativeSymbol);

        if (!pairExist) {
            TokenBase newToken = new TokenBase(
                wrappedName,
                wrappedSymbol,
                address(this)
            );

            tokenPairs[_erc20token] = address(newToken);
            newToken.allowAddress(this.owner());
        }

        assert(tokenPairs[_erc20token] != address(0));

        TokenBase(tokenPairs[_erc20token]).mint(_to, _ammount);
        emit TokenMinted(_to, tokenPairs[_erc20token], _ammount);
    }
}
