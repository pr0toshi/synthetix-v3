//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAccountRBACMixinModuleMock {
    function mockAccountRBACMixinDeposit(uint128 accountId, uint newDepositMock) external;

    function mockAccountRBACMixinMint(uint128 accountId, uint newMintMock) external;

    function mockAccountRBACMixinGetDepositMock() external view returns (uint);

    function mockAccountRBACMixinGetMintMock() external view returns (uint);
}