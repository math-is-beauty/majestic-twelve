// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


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

contract ChainlinkRateDistribution is Ownable {
    using SafeERC20 for IERC20;
    
    using SafeMath for uint;
    using SafeMath for uint256;

    AggregatorV3Interface internal dataFeed;

    IERC20 token;
    bool paused;
    bool multiply;
    uint256 minimumAmount;

    constructor(
        address _token,
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

        /**
         * Network: Arbitrum
         * Aggregator: ETH/USD
         * Address: 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612
         */
        // dataFeed = AggregatorV3Interface(
        //     0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612
        // );

        /**
         * Network: Sepolia
         * Aggregator: ETH/USD
         * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
         */
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
    }

    function sendTokens(
        address _to,
        uint256 _amount
    ) external {
        require(_amount >= minimumAmount, "Insufficient tokens provided.");
        require(!paused, "Distribution is paused.");

        tokenAccepted.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 tokensToPay = 0;
        if (multiply) {
            tokensToPay = _amount * rate;
        } else {
            tokensToPay = _amount / rate;
        }

        require(
            tokensToPay <= token.balanceOf(address(this)),
            "Not enough tokens available."
        );
        token.safeTransfer(_to, tokensToPay);
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

    /**
     * Returns the latest Chainlink answer.
     */
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

}
