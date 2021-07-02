// SPDX-License-Identifier: MIT

pragma solidity 0.8.5||0.7.6||0.6.12||0.5.16;

interface IDelegateOnlyERC725X {

  event Executed(address indexed _to, uint256 indexed _value, bytes _data);

  function execute(address to, uint256 value, bytes calldata data) external payable;
}
