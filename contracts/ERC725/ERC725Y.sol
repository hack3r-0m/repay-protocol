// SPDX-License-Identifier: MIT

pragma solidity 0.8.5||0.7.6||0.6.12||0.5.16;

// interfaces
import "../interfaces/IERC725Y.sol";

// modules
import "../utils/Ownable.sol";
import "../utils//ERC165.sol";

/* solhint-disable private-vars-leading-underscore */

/**
 * @title ERC725 Y data store
 * @dev Contract module which provides the ability to set arbitrary key value sets that can be changed over time.
 * It is intended to standardise certain keys value pairs to allow automated retrievals and interactions
 * from interfaces and other smart contracts.
 *
 * `setData` should only be callable by the owner of the contract set via ERC173.
 *
 */

contract ERC725Y is ERC165, Ownable, IERC725Y {

    bytes4 internal constant _INTERFACE_ID_ERC725Y = 0x2bd57b73;

    mapping(bytes32 => bytes) internal store;

    /**
     * @notice Sets the owner of the contract
     * @param _newOwner the owner of the contract.
     */
    
    constructor(address _newOwner) {
        // This is necessary to prevent a contract that implements both ERC725X and ERC725Y to call both constructors
        if(_newOwner != owner()) {
            transferOwnership(_newOwner);
        }

        _registerInterface(_INTERFACE_ID_ERC725Y);
    }

    /* Public functions */

    /**
     * @notice Gets data at a given `key`
     * @param _key the key which value to retrieve
     * @return _value The date stored at the key
     */
    
    function getData(bytes32 _key) public view override virtual returns (bytes memory _value) {
        return store[_key];
    }

    /**
     * @notice Sets data at a given `key`
     * @param _key the key which value to retrieve
     * @param _value the bytes to set.
     */
    
    function setData(bytes32 _key, bytes calldata _value) external override virtual onlyOwner {
        store[_key] = _value;
        emit DataChanged(_key, _value);
    }

    /* Modifiers */

}
