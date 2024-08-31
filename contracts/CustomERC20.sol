// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

interface IMintableERC20 {
    function mint(address _to, uint256 _amount) external;
}

contract CustomERC20 is IMintableERC20, ERC20, Ownable {
    /// @notice Decimals of the token
    uint8 private immutable DECIMALS;

    /// @notice Emitted whenever tokens are minted for an account.
    /// @param account Address of the account tokens are being minted for.
    /// @param amount  Amount of tokens minted.
    event Mint(address indexed account, uint256 amount);
    
    /// @param _name        ERC20 name.
    /// @param _symbol      ERC20 symbol.
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    )
        Ownable(msg.sender)
        ERC20(_name, _symbol)
    {
        DECIMALS = _decimals;
    }

    /// @notice Allows the owner to mint tokens.
    /// @param _to     Address to mint tokens to.
    /// @param _amount Amount of tokens to mint.
    function mint(
        address _to,
        uint256 _amount
    )
        external
        virtual
        override(IMintableERC20)
        onlyOwner
    {
        _mint(_to, _amount);
        emit Mint(_to, _amount);
    }

}
