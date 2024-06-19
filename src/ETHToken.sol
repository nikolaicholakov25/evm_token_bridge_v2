// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./TokenBase.sol";

contract ETHToken is TokenBase {
    constructor() TokenBase("ETHToken", "ETH", msg.sender) {}
}
