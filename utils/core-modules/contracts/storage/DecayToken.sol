//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

library DecayToken {
    bytes32 private constant _SLOT_DECAY_TOKEN_STORAGE =
        keccak256(abi.encode("io.synthetix.core-modules.DecayToken"));

    struct Data {
        /**
         * @dev decay rate in a year with 18 decimals (1e18 = 100%).
         */
        uint256 decayRate;
         /**
         * @dev timestamp saved on each interaction.
         */
        uint256 epochStart;
         /**
         * @dev total supply at the last interaction.
         */
        uint256 totalSupplyAtEpochStart;
    }

    function load() internal pure returns (Data storage store) {
        bytes32 s = _SLOT_DECAY_TOKEN_STORAGE;
        assembly {
            store.slot := s
        }
    }
}
