// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./TokenBase.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";

contract Bridge is Ownable {
    uint256 public fee;
    mapping(address => address) public nativeToWrappedTokens;
    mapping(address => address) public wrappedToNativeTokens;

    fallback() external payable {}
    receive() external payable {}

    constructor(address _initialOwner, uint256 _fee) Ownable(_initialOwner) {
        fee = _fee;
    }

    event TokenLocked(address _from, address _erc20token, uint256 _ammount);
    event TokenReleased(address _to, address _erc20token, uint256 _ammount);
    event TokenBurned(address _from, address _erc20token, uint256 _ammount);
    event TokenMinted(address _to, address _erc20token, uint256 _ammount);

    // error LockFailed(address _from, address _erc20token, uint256 _ammount);
    // error ReleaseFailed(address _to, address _erc20token, uint256 _ammount);

    error FeeNotPaid(address _from, uint256 _paid, uint256 _required);

    modifier chargeFee() {
        if (msg.value < fee) {
            revert FeeNotPaid(msg.sender, msg.value, fee);
        }
        _;
    }

    function updateFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function lock(
        address _from,
        address _erc20token,
        uint256 _ammount
    ) external payable chargeFee {
        TokenBase token = TokenBase(_erc20token);
        bool success = token.transferFrom(_from, address(this), _ammount);

        // if (!success) {
        //     revert LockFailed(_from, _erc20token, _ammount);
        // }

        emit TokenLocked(_from, _erc20token, _ammount);
    }

    function release(
        address _to,
        address _erc20token,
        uint256 _ammount
    ) external onlyOwner {
        TokenBase token = TokenBase(_erc20token);
        bool success = token.transfer(_to, _ammount);

        // if (!success) {
        //     revert ReleaseFailed(_to, _erc20token, _ammount);
        // }

        emit TokenReleased(_to, _erc20token, _ammount);
    }

    function burn(
        address _from,
        address _erc20token,
        uint256 _ammount
    ) external payable chargeFee {
        TokenBase wrappedToken = TokenBase(_erc20token);
        wrappedToken.burnFrom(_from, _ammount);

        emit TokenBurned(_from, wrappedToNativeTokens[_erc20token], _ammount);
    }

    function mint(
        address _to,
        address _erc20token,
        uint256 _ammount,
        string calldata name,
        string calldata symbol
    ) external onlyOwner {
        address wrappedTokenAddress = nativeToWrappedTokens[_erc20token];
        TokenBase nativeToken = TokenBase(_erc20token);
        TokenBase wrappedToken;

        if (wrappedTokenAddress != address(0)) {
            wrappedToken = TokenBase(wrappedTokenAddress);
        } else {
            string memory wrappedName = string.concat("Wrapped", name);
            string memory wrappedSymbol = string.concat("W", symbol);

            wrappedToken = new TokenBase(
                wrappedName,
                wrappedSymbol,
                address(this)
            );

            nativeToWrappedTokens[_erc20token] = address(wrappedToken);
            wrappedToNativeTokens[address(wrappedToken)] = _erc20token;

            wrappedToken.allowAddress(this.owner());
        }
        // assert(nativeToWrappedTokens[_erc20token] != address(0));

        wrappedToken.mint(_to, _ammount);
        emit TokenMinted(_to, nativeToWrappedTokens[_erc20token], _ammount);

        // return address(0x0);
    }
}
