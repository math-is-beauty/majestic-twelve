// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

}

contract FixedRateDistribution is Ownable {
    using SafeERC20 for IERC20;
    
    using SafeMath for uint;
    using SafeMath for uint256;

    IERC20 token;
    bool paused;
    bool multiply;
    uint256 rate;
    uint256 minimumAmount;

    constructor(
        address _token,
        bool _paused,
        bool _multiply,
        uint256 _rate,
        uint256 _minimumAmount
    )
        Ownable(msg.sender)
    {
        paused = _paused;
        multiply = _multiply;
        rate = _rate;
        minimumAmount = _minimumAmount;

        token = IERC20(_token);
    }

    receive() external payable {
        require(msg.value >= minimumAmount, "Insufficient ETH provided.");
        require(!paused, "Distribution is paused.");

        uint256 tokensToPay = 0;
        if (multiply) {
            tokensToPay = msg.value * rate;
        } else {
            tokensToPay = msg.value / rate;
        }

        require(
            tokensToPay <= token.balanceOf(address(this)),
            "Not enough tokens available."
        );
        token.safeTransfer(msg.sender, tokensToPay);
    }

    function setPaused(
        bool _paused
    )
        external
        onlyOwner
    {
        paused = _paused;
    }

    function setRate(
        uint256 _rate
    )
        external
        onlyOwner
    {
        rate = _rate;
    }

    function setMinimumAmount(
        uint256 _minimumAmount
    )
        external
        onlyOwner
    {
        minimumAmount = _minimumAmount;
    }

    function setMultiply(
        bool _multiply
    )
        external
        onlyOwner
    {
        multiply = _multiply;
    }

    function withdrawToken(
        address tokenAddress,
        address to,
        uint256 amount
    )
        external
        onlyOwner
    {
        IERC20(tokenAddress).safeTransfer(to, amount);
    }

    function withdrawETH(
        address payable _to,
        uint256 amount
    )
        external
        onlyOwner
    {
        (bool sent, ) = _to.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

}
