// SPDX-License-Identifier: MIT

pragma solidity 0.8.5||0.7.6||0.6.12||0.5.16;
pragma experimental ABIEncoderV2;

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

contract WhitelistPaymaster is BasePaymaster {

  bool public useSenderWhitelist;
  bool public useTargetWhitelist;

  mapping(address => bool) public senderWhitelist;
  mapping(address => bool) public targetWhitelist;

  event Accepted(address indexed onBehlafOf, address indexed to, uint256 gas);

  function versionPaymaster() external view override virtual returns (string memory) {
    return "2.2.2+opengsn.whitelist.ipaymaster";
  }

  function whitelistSender(address sender) public onlyOwner {
    senderWhitelist[sender] = true;
    useSenderWhitelist = true;
  }

  function whitelistTarget(address target) public onlyOwner {
    targetWhitelist[target] = true;
    useTargetWhitelist = true;
  }

  function preRelayedCall(
    GsnTypes.RelayRequest calldata relayRequest,
    bytes calldata signature,
    bytes calldata approvalData,
    uint256 maxPossibleGas
  ) external view override returns (bytes memory context, bool revertOnRecipientRevert) {
    (relayRequest, signature, approvalData, maxPossibleGas);

    if (useSenderWhitelist) {
      require(senderWhitelist[relayRequest.request.from], "PAYMASTER: SENDER_NOT_WHITELISTED");
    }
    if (useTargetWhitelist) {
      require(targetWhitelist[relayRequest.request.to], "PAYMASTER: TARGET_NOT_WHITELISTED");
    }
    return (abi.encode(relayRequest.request.from, relayRequest.request.to), false);
  }

  function postRelayedCall(bytes calldata context, bool success, uint256 gasUseWithoutPost, GsnTypes.RelayData calldata relayData) external virtual override {
    (context, success, gasUseWithoutPost, relayData);

    if(success){
      (address _for, address _to) = abi.decode(context, (address, address));
      emit Accepted(_for, _to, gasUseWithoutPost);
    }
  }

}
