//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@synthetixio/core-contracts/contracts/satellite/SatelliteFactory.sol";

contract SNXTokenStorage {
    struct SNXTokenStore {
        bool initialized;
        SatelliteFactory.Satellite snxToken;
    }

    function _snxTokenStore() internal pure returns (SNXTokenStore storage store) {
        assembly {
            // bytes32(uint(keccak256("io.synthetix.snxtoken")) - 1)
            store.slot := 0x78bc705d9580e2bf0ac5fbdf5c64af541a07733f726449b1d576f551ba6de571
        }
    }
}