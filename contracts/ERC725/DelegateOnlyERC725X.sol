// SPDX-License-Identifier: Apache-2.0

pragma solidity 0.8.5||0.7.6||0.6.12||0.5.16;

import "../interfaces/IDelegateOnlyERC725X.sol";
import "../utils/ERC165.sol";

/* solhint-disable private-vars-leading-underscore */
/* solhint-disable no-inline-assembly */

/**
 * @title Partial implementation of ERC725 X which only allows to delegate call
 */

contract ERC725X is ERC165, IDelegateOnlyERC725X  {

    bytes4 internal constant _INTERFACE_ID_DELEGATE_ONLY_ERC725X = type(IDelegateOnlyERC725X).interfaceId;
    address public owner;
    
    constructor(address _owner) {
        owner = _owner;
        _registerInterface(_INTERFACE_ID_DELEGATE_ONLY_ERC725X);
    }

    /* Public functions */

    /**
     * @notice Executes any other smart contract. Is only callable by the owner.
     *
     * @param _to the smart contract or address to interact with.
     * @param _value the value of ETH to transfer.
     * @param _data the call data.
     */

    function execute(address _to, uint256 _value, bytes calldata _data) external payable override {
        emit Executed(_to, _value, _data);
    }

    /* Internal functions */

    /* https://github.com/gnosis/safe-contracts/blob/development/contracts/base/Executor.sol */

    function executeDelegateCall(address to, bytes memory data, uint256 txGas) internal returns (bool success) {
        assembly {
            success := delegatecall(txGas, to, add(data, 0x20), mload(data), 0, 0)
        }
    }

}
