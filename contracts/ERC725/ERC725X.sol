// SPDX-License-Identifier: MIT

pragma solidity 0.8.5||0.7.6||0.6.12||0.5.16;

// interfaces
import "../interfaces/IERC725X.sol";

// modules
import "../utils/Ownable.sol";
import "../utils/ERC165.sol";

// libraries
import "../utils/Create2.sol";
import "../utils/BytesLib.sol";

/* solhint-disable private-vars-leading-underscore */
/* solhint-disable no-inline-assembly */
/* solhint-disable max-line-length */

/**
 * @title ERC725 X executor
 * @dev Implementation which provides the ability to call arbitrary functions at any other smart contract and itself,
 * including using `delegatecall`, as well creating contracts using `create` and `create2`.
 * This is the basis for a smart contract based account system, but could also be used as a proxy account system.
 *
 * `execute` MUST only be called by the owner of the contract set via ERC173.
 *
 */

contract ERC725X is ERC165, Ownable, IERC725X  {

    bytes4 internal constant _INTERFACE_ID_ERC725X = 0x44c028fe;

    uint256 public constant OPERATION_CALL = 0;
    uint256 public constant OPERATION_DELEGATECALL = 1;
    uint256 public constant OPERATION_CREATE2 = 2;
    uint256 public constant OPERATION_CREATE = 3;

    /**
     * @notice Sets the owner of the contract
     * @param _newOwner the owner of the contract.
     */

    constructor(address _newOwner) {
        // This is necessary to prevent a contract that implements both ERC725X and ERC725Y to call both constructors
        if(_newOwner != owner()) {
            transferOwnership(_newOwner);
        }

        _registerInterface(_INTERFACE_ID_ERC725X);
    }

    /* Public functions */

    /**
     * @notice Executes any other smart contract. Is only callable by the owner.
     *
     *
     * @param _operation the operation to execute: CALL = 0; DELEGATECALL = 1; CREATE2 = 2; CREATE = 3;
     * @param _to the smart contract or address to interact with. `_to` 
     *           will be unused if a contract is created (operation 2 and 3)
     * @param _value the value of ETH to transfer
     * @param _data the call data, or the contract data to deploy
     */

    function execute(uint256 _operation, address _to, uint256 _value, bytes calldata _data) external payable override onlyOwner {
        // emit event
        emit Executed(_operation, _to, _value, _data);

        uint256 txGas = gasleft() - 2500;

        // CALL
        if (_operation == OPERATION_CALL) {
            executeCall(_to, _value, _data, txGas);

        // DELEGATE CALL
        /* TODO: risky as storage slots can be overridden, remove? */

        /**

        } else if (_operation == OPERATION_DELEGATECALL) {
            address currentOwner = owner();
            executeDelegateCall(_to, _data, txGas);
            // Check that the owner was not overridden
            require(owner() == currentOwner, "Delegate call is not allowed to modify the owner!");

        */

        // CREATE
        } else if (_operation == OPERATION_CREATE) {
            performCreate(_value, _data);

        // CREATE2
        } else if (_operation == OPERATION_CREATE2) {
            bytes32 salt = BytesLib.toBytes32(_data, _data.length - 32);
            bytes memory data = BytesLib.slice(_data, 0, _data.length - 32);

            address contractAddress = Create2.deploy(_value, salt, data);

            emit ContractCreated(contractAddress);

        } else {
            revert("Wrong operation type");
        }
    }

    /* Internal functions */

    // Taken from GnosisSafe
    // https://github.com/gnosis/safe-contracts/blob/development/contracts/base/Executor.sol

    function executeCall(address to, uint256 value, bytes memory data, uint256 txGas) internal returns (bool success) {
        assembly {
            success := call(txGas, to, value, add(data, 0x20), mload(data), 0, 0)
        }
    }

    // Taken from GnosisSafe
    // https://github.com/gnosis/safe-contracts/blob/development/contracts/base/Executor.sol

    function executeDelegateCall(address to, bytes memory data, uint256 txGas) internal returns (bool success) {
        assembly {
            success := delegatecall(txGas, to, add(data, 0x20), mload(data), 0, 0)
        }
    }

    // Taken from GnosisSafe
    // https://github.com/gnosis/safe-contracts/blob/development/contracts/libraries/CreateCall.sol

    function performCreate(uint256 value, bytes memory deploymentData) internal returns (address newContract) {
        assembly {
            newContract := create(value, add(deploymentData, 0x20), mload(deploymentData))
        }
        require(newContract != address(0), "Could not deploy contract");
        emit ContractCreated(newContract);
    }

    /* Modifiers */

}
