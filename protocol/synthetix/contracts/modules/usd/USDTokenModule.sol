//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../../interfaces/IUSDTokenModule.sol";
import "../../storage/CrossChain.sol";

import "@synthetixio/core-modules/contracts/storage/AssociatedSystem.sol";
import "@synthetixio/core-contracts/contracts/token/ERC20.sol";
import "@synthetixio/core-modules/contracts/storage/FeatureFlag.sol";
import "@synthetixio/core-contracts/contracts/initializable/InitializableMixin.sol";
import "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";

/**
 * @title Module for managing the snxUSD token as an associated system.
 * @dev See IUSDTokenModule.
 */
contract USDTokenModule is ERC20, InitializableMixin, IUSDTokenModule {
    using AssociatedSystem for AssociatedSystem.Data;
    using CrossChain for CrossChain.Data;

    uint256 private constant _TRANSFER_GAS_LIMIT = 100000;

    bytes32 private constant _CCIP_CHAINLINK_TOKEN_POOL = "ccipChainlinkTokenPool";
    bytes32 internal constant _TRANSFER_CROSS_CHAIN_FEATURE_FLAG = "transferCrossChain";

    /**
     * @dev For use as an associated system.
     */
    function _isInitialized() internal view override returns (bool) {
        return ERC20Storage.load().decimals != 0;
    }

    /**
     * @dev For use as an associated system.
     */
    function isInitialized() external view returns (bool) {
        return _isInitialized();
    }

    /**
     * @dev For use as an associated system.
     */
    function initialize(
        string memory tokenName,
        string memory tokenSymbol,
        uint8 tokenDecimals
    ) public virtual {
        OwnableStorage.onlyOwner();
        _initialize(tokenName, tokenSymbol, tokenDecimals);
    }

    /**
     * @dev Allows the core system and CCIP to mint tokens.
     */
    function mint(address target, uint256 amount) external override {
        if (
            msg.sender != OwnableStorage.getOwner() &&
            msg.sender != AssociatedSystem.load(_CCIP_CHAINLINK_TOKEN_POOL).proxy
        ) {
            revert AccessError.Unauthorized(msg.sender);
        }

        _mint(target, amount);
    }

    /**
     * @dev Allows the core system and CCIP to burn tokens.
     */
    function burn(address target, uint256 amount) external override {
        if (
            msg.sender != OwnableStorage.getOwner() &&
            msg.sender != AssociatedSystem.load(_CCIP_CHAINLINK_TOKEN_POOL).proxy
        ) {
            revert AccessError.Unauthorized(msg.sender);
        }

        _burn(target, amount);
    }

    /**
     * @inheritdoc IUSDTokenModule
     */
    function burnWithAllowance(address from, address spender, uint256 amount) external {
        OwnableStorage.onlyOwner();

        ERC20Storage.Data storage erc20 = ERC20Storage.load();

        if (amount > erc20.allowance[from][spender]) {
            revert InsufficientAllowance(amount, erc20.allowance[from][spender]);
        }

        erc20.allowance[from][spender] -= amount;

        _burn(from, amount);
    }

    /**
     * @inheritdoc IUSDTokenModule
     */
    function transferCrossChain(
        uint64 destChainId,
        address to,
        uint256 amount
    ) external payable returns (uint256 gasTokenUsed) {
        FeatureFlag.ensureAccessToFeature(_TRANSFER_CROSS_CHAIN_FEATURE_FLAG);

        _burn(msg.sender, amount);

        gasTokenUsed = CrossChain.load().transmit(
            destChainId,
            abi.encodeWithSelector(this.mint.selector, to, amount),
            _TRANSFER_GAS_LIMIT
        );
    }

    /**
     * @dev Included to satisfy ITokenModule inheritance.
     */
    function setAllowance(address from, address spender, uint256 amount) external override {
        OwnableStorage.onlyOwner();
        ERC20Storage.load().allowance[from][spender] = amount;
    }
}
