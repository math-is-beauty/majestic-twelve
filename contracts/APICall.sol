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

    struct ServiceProvider {
        // Stores the PGP public key of the service provider
        bytes publicKey;
    }

    struct Service {
        uint256 serviceProvider;
        bool isOnline;
        // In ms. If it is zero, then it cannot timeout
        uint256 maxTimeout;
        uint256 pricePerCall;
        // In ms. If it is zero, response will be instantly deleted after being returned once
        uint256 responseStoredFor;
    }

    IERC20 token;

    mapping(uint => ServiceProvider) serviceProviderMap;
    uint256 totalServiceProviders;

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

        totalServiceProviders = 0;
        totalServices = 0;

        token = IERC20(_token);
    }

    function makeApiCall(
        uint256 serviceId
    ) external payable {
        require(serviceId < totalServices, "Service ID not found.");
        
    }

    function setPaused(
        bool _paused
    )
        external
        onlyOwner
    {
        paused = _paused;
    }

    function addServiceProvider(
        bytes calldata publicKey
    )
        external
        onlyOwner
    {
        serviceProviderMap[totalServiceProviders] = ServiceProvider(publicKey);

        totalServiceProviders = totalServiceProviders + 1;
    }

    function editServiceProvider(
        uint256 serviceProviderId,
        bytes calldata publicKey
    )
        external
        onlyOwner
    {
        require(serviceProviderId < totalServiceProviders, "Service provider not found.");

        serviceProviderMap[serviceProviderId] = ServiceProvider(publicKey);
    }

    function addService(
        uint256 serviceProviderId,
        bool isOnline,
        uint256 maxTimeout,
        uint256 pricePerCall,
        uint256 responseStoredFor
    )
        external
        onlyOwner
    {
        require(serviceProviderId < totalServiceProviders, "Service provider not found.");

        serviceMap[totalServices] = Service(serviceProviderId, isOnline, maxTimeout, pricePerCall, responseStoredFor);

        totalServices = totalServices + 1;
    }

    function editService(
        uint256 serviceId,
        uint256 serviceProviderId,
        bool isOnline,
        uint256 maxTimeout,
        uint256 pricePerCall,
        uint256 responseStoredFor
    )
        external
        onlyOwner
    {
        require(serviceId < totalServices, "Service ID not found.");
        serviceMap[serviceId] = Service(serviceProviderId, isOnline, maxTimeout, pricePerCall, responseStoredFor);
    }

    function getServiceProvider(
        uint256 serviceProviderId
    ) external view returns(ServiceProvider memory) {
        return serviceProviderMap[serviceProviderId];
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
