// SPDX-License-Identifier: MIT

pragma solidity 0.8.5||0.7.6||0.6.12||0.5.16;

interface IWhitelistPaymaster {

  function whitelistSender(address) external;
  function whitelistTarget(address) external;
  
  function isWhitelistedTarget(address _target) external view returns (bool);
  function isWhitelistedSender(address _sender) external view returns (bool);

}
