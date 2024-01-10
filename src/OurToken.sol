// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin-tokens/ERC20/ERC20.sol";

contract OurToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MARIO TOKEN", "MTO") {
        _mint(msg.sender, initialSupply);
    }
}
