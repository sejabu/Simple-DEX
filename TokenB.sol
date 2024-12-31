// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/* @title TokenB
 * @author Bugallo Sergio
 * @dev Only for educational purposes, implements a TokenB using Openzeppelin's contracts.
 * @notice Trabajo Final Buenos Aires EDP Modulo3 (ETHKIPU) 
 * @custom:security-contact mysecurityagent@TP3-ETHKIPU.xxx
 */

contract TokenB is ERC20, Ownable {
    constructor()
        ERC20("TokenB", "TKB")
        Ownable(msg.sender)
    {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}