// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { OracleLibrary } from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";


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

contract UniswapV3RateDistribution is Ownable {
    using SafeERC20 for IERC20;
    
    using SafeMath for uint;
    using SafeMath for uint256;

    address poolAddress;

    IERC20 token;
    bool paused;
    bool multiply;
    uint256 minimumAmount;

    constructor(
        address _token,
        address _poolAddress,
        bool _paused,
        bool _multiply,
        uint256 _minimumAmount
    )
        Ownable(msg.sender)
    {
        paused = _paused;
        multiply = _multiply;
        minimumAmount = _minimumAmount;

        token = IERC20(_token);

        poolAddress = _poolAddress;
    }

    receive() external payable {
        require(msg.value >= minimumAmount, "Insufficient ETH provided.");
        require(!paused, "Distribution is paused.");

        (int24 arithmeticMeanTick, ) = OracleLibrary.consult(
            poolAddress, 60
        );
        
        uint256 rate = uint256(uint24(arithmeticMeanTick));

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
