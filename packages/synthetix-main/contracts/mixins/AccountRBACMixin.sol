//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../storage/AccountModuleStorage.sol";

contract AccountRBACMixin is AccountModuleStorage {
    using SetUtil for SetUtil.Bytes32Set;

    error PermissionDenied(uint accountId, bytes32 permission, address target);

    bytes32 internal constant _DEPOSIT_PERMISSION = "DEPOSIT";
    bytes32 internal constant _WITHDRAW_PERMISSION = "WITHDRAW";
    bytes32 internal constant _DELEGATE_PERMISSION = "DELEGATE";
    bytes32 internal constant _MINT_PERMISSION = "MINT";
    bytes32 internal constant _ADMIN_PERMISSION = "ADMIN";

    modifier onlyWithPermission(uint accountId, bytes32 permission) {
        if (!_authorized(accountId, permission, msg.sender)) {
            revert PermissionDenied(accountId, permission, msg.sender);
        }

        _;
    }

    function _hasPermission(
        uint256 accountId,
        bytes32 permission,
        address target
    ) internal view returns (bool) {
        AccountRBAC storage accountRBAC = _accountModuleStore().accountsRBAC[accountId];

        return target != address(0) && accountRBAC.permissions[target].contains(permission);
    }

    function _authorized(
        uint accountId,
        bytes32 permission,
        address target
    ) internal view returns (bool) {
        return ((target == _accountOwner(accountId)) ||
            _hasPermission(accountId, _ADMIN_PERMISSION, target) ||
            _hasPermission(accountId, permission, target));
    }

    function _accountOwner(uint accountId) internal view returns (address) {
        return _accountModuleStore().accountsRBAC[accountId].owner;
    }
}
