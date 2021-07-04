// SPDX-License-Identifier: MIT

pragma solidity 0.8.5||0.7.6||0.6.12||0.5.16;
pragma experimental ABIEncoderV2;

import "../interfaces/IWhitelistPaymaster.sol";
import "@opengsn/contracts/src/BasePaymaster.sol";

/* solhint-disable no-unused-vars */
/* solhint-disable max-line-length */

/**

 * A sample paymaster that has whitelists for senders and targets.

 * If at least one sender is whitelisted, then ONLY whitelisted senders are allowed.
 * If at least one target is whitelisted, then ONLY whitelisted targets are allowed.

 */

/**

 * Parameters(Gas & Data limits) are kept as default from BasePaymaster

 * FORWARDER_HUB_OVERHEAD = 50000 (overhead of forwarder verify+signature, plus hub overhead.)
 * PRE_RELAYED_CALL_GAS_LIMIT = 100000
 * POST_RELAYED_CALL_GAS_LIMIT = 110000
 * PAYMASTER_ACCEPTANCE_BUDGET = PRE_RELAYED_CALL_GAS_LIMIT + FORWARDER_HUB_OVERHEAD
 * CALLDATA_SIZE_LIMIT = 10500

 */

contract WhitelistPaymaster is IWhitelistPaymaster, BasePaymaster {

  mapping(address => bool) public senderWhitelist;
  mapping(address => bool) public targetWhitelist;

  function versionPaymaster() external view override virtual returns (string memory) {
    return "2.2.2+opengsn.whitelist.ipaymaster";
  }

  function isWhitelistedTarget(address _target) external view override returns (bool) {
    return targetWhitelist[_target];
  }

  function isWhitelistedSender(address _sender) external view override returns (bool) {
    return senderWhitelist[_sender];
  }

  function whitelistSender(address sender) external override onlyOwner {
    senderWhitelist[sender] = true;
  }

  function whitelistTarget(address target) external override onlyOwner {
    targetWhitelist[target] = true;
  }

  function preRelayedCall(
    GsnTypes.RelayRequest calldata relayRequest,
    bytes calldata signature,
    bytes calldata approvalData,
    uint256 maxPossibleGas
  ) external view override returns (bytes memory context, bool revertOnRecipientRevert) {
    (relayRequest, signature, approvalData, maxPossibleGas); // to remove unused params warning from compiler

    require(senderWhitelist[relayRequest.request.from], "PAYMASTER: SENDER_NOT_WHITELISTED");
    require(targetWhitelist[relayRequest.request.to], "PAYMASTER: TARGET_NOT_WHITELISTED");

    return (abi.encode(relayRequest.request.from, relayRequest.request.to), false);
  }

  function postRelayedCall(bytes calldata context, bool success, uint256 gasUseWithoutPost, GsnTypes.RelayData calldata relayData) external virtual override {
    (context, success, gasUseWithoutPost, relayData); // to remove unused params warning from compiler

    if(success){
      (address _for, address _to) = abi.decode(context, (address, address));
      emit Accepted(_for, _to, gasUseWithoutPost);
    }
  }

}
