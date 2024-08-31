// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
    
    using SafeMath for uint;
    using SafeMath for uint256;

    IERC20 token;
    bool paused;
    uint256 rate;

    constructor(
        address _token,
        bool _paused,
        uint256 _rate
    )
        Ownable(msg.sender)
    {
        paused = _paused;
        rate = _rate;

        token = IERC20(_token);
    }

    receive() external payable {
        require(!paused, "Distribution is paused.");

        uint256 tokensToPay = msg.value * rate;

        require(
            tokensToPay <= token.balanceOf(address(this)),
            "Not enough tokens available."
        );
        token.transfer(msg.sender, tokensToPay);
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

    function withdraw(
        address to,
        uint256 amount
    )
        external
        onlyOwner
    {
        token.transfer(to, amount);
    }

}
