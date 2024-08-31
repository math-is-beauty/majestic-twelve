// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

interface IMintableERC20 {
    function mint(address _to, uint256 _amount) external;
}

contract CustomERC20 is IMintableERC20, ERC20, ERC20Permit, Ownable {

    /// @notice Decimals of the token
    uint8 private immutable DECIMALS;

    /// @notice Emitted whenever tokens are minted for an account.
    /// @param account Address of the account tokens are being minted for.
    /// @param amount  Amount of tokens minted.
    event Mint(address indexed account, uint256 amount);

    /// @notice Emitted whenever tokens are burned from an account.
    /// @param account Address of the account tokens are being burned from.
    /// @param amount  Amount of tokens burned.
    event Burn(address indexed account, uint256 amount);
    
    /// @param _name        ERC20 name.
    /// @param _symbol      ERC20 symbol.
    /// @param _decimals      ERC20 decimals. NOTE: This information is only used for _display_ purposes
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    )
        Ownable(msg.sender)
        ERC20(_name, _symbol)
        ERC20Permit(_name)
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

    /// @notice Allows a user to burn tokens.
    /// @param _amount Amount of tokens to burn.
    function burn(
        uint256 _amount
    )
        external
    {
        _burn(msg.sender, _amount);
        emit Burn(msg.sender, _amount);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, deducting from
     * the caller's allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `value`.
     */
    function burnFrom(address account, uint256 value) external {
        _spendAllowance(account, msg.sender, value);
        _burn(account, value);
        emit Burn(account, value);
    }

    /// @dev Returns the number of decimals used to get its user representation.
    /// For example, if `decimals` equals `2`, a balance of `505` tokens should
    /// be displayed to a user as `5.05` (`505 / 10 ** 2`).
    /// NOTE: This information is only used for _display_ purposes: it in
    /// no way affects any of the arithmetic of the contract, including
    /// {IERC20-balanceOf} and {IERC20-transfer}.
    function decimals() public view override returns (uint8) {
        return DECIMALS;
    }

}
