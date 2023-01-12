//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {UUPSProxyWithOwner} from "@synthetixio/core-contracts/contracts/proxy/UUPSProxyWithOwner.sol";
import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";

contract Proxy is UUPSProxyWithOwner {
    // solhint-disable-next-line no-empty-blocks
    constructor(
        address firstImplementation,
        address initialOwner
    ) UUPSProxyWithOwner(firstImplementation, initialOwner) {}
}
