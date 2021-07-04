// SPDX-License-Identifier: MIT
pragma solidity 0.8.5||0.7.6||0.6.12||0.5.16;

// modules
import "./ERC725X.sol";
import "./ERC725Y.sol";

/* solhint-disable no-empty-blocks */

/**
 * @title ERC725 bundle
 * @dev Bundles ERC725X and ERC725Y together into one smart contract
 *
 */

contract ERC725 is ERC725X, ERC725Y  {

    /**
     * @notice Sets the owner of the contract
     * @param _newOwner the owner of the contract.
     */
    
    constructor(address _newOwner) ERC725X(_newOwner) ERC725Y(_newOwner) {}

    /* NOTE this implementation has not by default: receive() external payable {} */
}
