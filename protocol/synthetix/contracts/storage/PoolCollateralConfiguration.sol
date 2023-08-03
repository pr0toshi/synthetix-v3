//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

library PoolCollateralConfiguration {
    bytes32 private constant _SLOT =
        keccak256(abi.encode("io.synthetix.synthetix.PoolCollateralConfiguration"));

    struct Data {
        bool collateralTypeDisabled;
        uint256 issuanceRatioD18;
    }
}
