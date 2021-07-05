// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "../interactor/UniswapInteractionProxy.sol";
import "../utils/ERC2771Context.sol";
import "../interfaces/IWhitelistPaymaster.sol";

/* solhint-disable var-name-mixedcase */
/* solhint-disable func-param-name-mixedcase */
/* solhint-disable no-inline-assembly */
/* solhint-disable max-line-length */

contract InteractionProxyDeployer is ERC2771Context {

  /**
   * @notice 
   * EOA will deploy paymaster and then will change ownership of paymaster to ProxyDepolyer
   * So ProxyDepolyer(this contract) can whitelist senders
   */

  address public paymaster;

  constructor(address _trustedForwarder, address _paymaster) ERC2771Context(_trustedForwarder) {
      paymaster = _paymaster;
  }

  address public constant UNISWAP_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address public constant SUSHISWAP_ROUTER = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
  address public constant QUICKSWAP_ROUTER = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;

  address public constant UNISWAP_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
  address public constant SUSHISWAP_FACTORY = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
  address public constant QUICKSWAP_FACTORY = 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32;

  address public constant FORWARDER_MAINNET = 0xAa3E82b4c4093b4bA13Cb5714382C99ADBf750cA;
  address public constant FORWARDER_KOVAN = 0x7eEae829DF28F9Ce522274D5771A6Be91d00E5ED;
  address public constant FORWARDER_RINKEBY = 0x83A54884bE4657706785D7309cf46B58FE5f6e8a;
  address public constant FORWARDER_POLYGON = 0xdA78a11FD57aF7be2eDD804840eA7f4c2A38801d;

  event ProxyDeployed(address indexed deployer, address indexed proxy);

  mapping (address => address) public proxyToOwner;

  function versionRecipient() external pure returns (string memory) {
    return "2.2.2";
  }

  function _getChainID() internal pure returns (uint256 id) {
    assembly {
      id := chainid()
    }
  }

  function getProxyOwner(address _proxy) external view returns (address) {
    return proxyToOwner[_proxy];
  }

  /**
   * If chainId is 1:
   *      choice true: deploy uniswap
   *      choice false: deploy sushiswap
   *
   * Else if chainId is {4,42}:
   *      deploy uniswap
   *
   * Else if chainId is 137:
   *      deploy quickswap
   */

  function deploy(bool choice) external returns (address _proxyAddress) {

    uint256 chainId = _getChainID();
    
    address _router;
    address _forwarder;
    address _factory;

    if (chainId == 1) {

      if (choice) {
        _router = UNISWAP_ROUTER;_factory = UNISWAP_FACTORY;_forwarder = FORWARDER_MAINNET; } 
      else {
        _router = SUSHISWAP_ROUTER;_factory = SUSHISWAP_FACTORY;_forwarder = FORWARDER_MAINNET; } }

    else if (chainId == 4) {
      _router = UNISWAP_ROUTER;_factory = UNISWAP_FACTORY;_forwarder = FORWARDER_RINKEBY; }
    else if (chainId == 42) {
      _router = UNISWAP_ROUTER;_factory = UNISWAP_FACTORY;_forwarder = FORWARDER_RINKEBY; }
    else if (chainId == 137) {
      _router = QUICKSWAP_ROUTER;_factory = QUICKSWAP_FACTORY;_forwarder = FORWARDER_POLYGON; } 
    else {
      revert("NO_FEASIBLE_CHAIN_ID"); }

    UniswapInteractionProxy proxy = new UniswapInteractionProxy(_forwarder, _msgSender(), address(this), _router, _factory);

    _proxyAddress = address(proxy);
    emit ProxyDeployed(_msgSender(), _proxyAddress);

    proxyToOwner[_proxyAddress] = _msgSender();

    IWhitelistPaymaster(paymaster).whitelistSender(_proxyAddress);
  }

}
