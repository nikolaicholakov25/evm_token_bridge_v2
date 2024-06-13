// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./TokenBase.sol";

contract WETHToken is TokenBase {
    constructor() TokenBase("WETHToken", "WETH", msg.sender) {}
}
