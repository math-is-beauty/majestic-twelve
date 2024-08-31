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

contract APICall is Ownable {
    using SafeERC20 for IERC20;
    
    using SafeMath for uint;
    using SafeMath for uint256;

    struct Service {
        bool isOnline;
        // In ms. If it is zero, then it cannot timeout
        uint256 maxTimeout;
        uint256 pricePerCall;
    }

    IERC20 token;

    mapping(uint => Service) serviceMap;
    uint256 totalServices;

    bool paused;

    constructor(
        address _token,
        bool _paused
    )
        Ownable(msg.sender)
    {
        paused = _paused;

        totalServices = 0;

        token = IERC20(_token);
    }

    function makeApiCall(
        uint256 serviceId
    ) external payable {

    }

    function setPaused(
        bool _paused
    )
        external
        onlyOwner
    {
        paused = _paused;
    }

    function addService(
        bool isOnline,
        uint256 maxTimeout,
        uint256 pricePerCall
    )
        external
        onlyOwner
    {
        serviceMap[totalServices] = Service(isOnline, maxTimeout, pricePerCall);

        totalServices = totalServices + 1;
    }

    function editService(
        uint256 serviceId,
        bool isOnline,
        uint256 maxTimeout,
        uint256 pricePerCall
    )
        external
        onlyOwner
    {
        require(serviceId < totalServices, "Service ID not found.");
        serviceMap[serviceId] = Service(isOnline, maxTimeout, pricePerCall);
    }

    function getService(
        uint256 serviceId
    ) external view returns(Service memory) {
        return serviceMap[serviceId];
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
