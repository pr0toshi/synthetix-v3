//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {SettlementStrategy} from "../storage/SettlementStrategy.sol";
import {PerpsMarketConfiguration} from "../storage/PerpsMarketConfiguration.sol";
import {OrderFee} from "../storage/OrderFee.sol";

/**
 * @title Module for updating configuration in relation to async order modules.
 */
interface IMarketConfigurationModule {
    /**
     * @notice Gets fired when new settlement strategy is added.
     * @param marketId adds settlement strategy to this specific market.
     * @param strategy the strategy configuration.
     * @param strategyId the newly created settlement strategy id.
     */
    event SettlementStrategyAdded(
        uint128 indexed marketId,
        SettlementStrategy.Data strategy,
        uint256 indexed strategyId
    );

    /**
     * @notice Gets fired when feed id for perps market is updated.
     * @param marketId id of perps market
     * @param feedId oracle node id
     */
    event MarketPriceDataUpdated(uint128 indexed marketId, bytes32 feedId);

    /**
     * @notice Gets fired when order fees are updated.
     * @param marketId udpates fees to this specific market.
     * @param makerFeeRatio the maker fee ratio.
     * @param takerFeeRatio the taker fee ratio.
     */
    event OrderFeesSet(uint128 indexed marketId, uint256 makerFeeRatio, uint256 takerFeeRatio);

    /**
     * @notice Gets fired when funding parameters are updated.
     * @param marketId udpates funding parameters to this specific market.
     * @param skewScale the skew scale.
     * @param maxFundingVelocity the max funding velocity.
     */
    event FundingParametersSet(
        uint128 indexed marketId,
        uint256 skewScale,
        uint256 maxFundingVelocity
    );

    /**
     * @notice Gets fired when liquidation parameters are updated.
     * @param marketId udpates funding parameters to this specific market.
     * @param initialMarginRatioD18 the initial margin ratio (as decimal with 18 digits precision).
     * @param maintenanceMarginRatioD18 the maintenance margin ratio (as decimal with 18 digits precision).
     * @param liquidationRewardRatioD18 the liquidation reward ratio (as decimal with 18 digits precision).
     * @param maxLiquidationLimitAccumulationMultiplier the max liquidation limit accumulation multiplier.
     * @param maxSecondsInLiquidationWindow the max seconds in liquidation window (used together with the acc multiplier to get max liquidation per window).
     * @param minimumPositionMargin the minimum position margin.
     */
    event LiquidationParametersSet(
        uint128 indexed marketId,
        uint256 initialMarginRatioD18,
        uint256 maintenanceMarginRatioD18,
        uint256 liquidationRewardRatioD18,
        uint256 maxLiquidationLimitAccumulationMultiplier,
        uint256 maxSecondsInLiquidationWindow,
        uint256 minimumPositionMargin
    );

    /**
     * @notice Gets fired when max market value is updated.
     * @param marketId udpates funding parameters to this specific market.
     * @param maxMarketSize the max market value.
     */
    event MaxMarketSizeSet(uint128 indexed marketId, uint256 maxMarketSize);

    /**
     * @notice Gets fired when locked oi ratio is updated.
     * @param marketId udpates funding parameters to this specific market.
     * @param lockedOiRatioD18 the locked OI ratio skew scale (as decimal with 18 digits precision).
     */
    event LockedOiRatioD18Set(uint128 indexed marketId, uint256 lockedOiRatioD18);

    /**
     * @notice Gets fired when a settlement strategy is enabled or disabled.
     * @param marketId udpates funding parameters to this specific market.
     * @param strategyId the specific strategy.
     * @param enabled whether the strategy is enabled or disabled.
     */
    event SettlementStrategyEnabled(uint128 indexed marketId, uint256 strategyId, bool enabled);

    /**
     * @notice Add a new settlement strategy with this function.
     * @param marketId id of the market to add the settlement strategy.
     * @param strategy strategy details (see SettlementStrategy.Data struct).
     * @return strategyId id of the new settlement strategy.
     */
    function addSettlementStrategy(
        uint128 marketId,
        SettlementStrategy.Data memory strategy
    ) external returns (uint256 strategyId);

    /**
     * @notice Set order fees for a market with this function.
     * @param marketId id of the market to set order fees.
     * @param makerFeeRatio the maker fee ratio.
     * @param takerFeeRatio the taker fee ratio.
     */
    function setOrderFees(uint128 marketId, uint256 makerFeeRatio, uint256 takerFeeRatio) external;

    /**
     * @notice Set node id for perps market
     * @param perpsMarketId id of the market to set price feed.
     * @param feedId the node feed id
     */
    function updatePriceData(uint128 perpsMarketId, bytes32 feedId) external;

    /**
     * @notice Set funding parameters for a market with this function.
     * @param marketId id of the market to set funding parameters.
     * @param skewScale the skew scale.
     * @param maxFundingVelocity the max funding velocity.
     */
    function setFundingParameters(
        uint128 marketId,
        uint256 skewScale,
        uint256 maxFundingVelocity
    ) external;

    /**
     * @notice Set liquidation parameters for a market with this function.
     * @param marketId id of the market to set liquidation parameters.
     * @param initialMarginRatioD18 the initial margin ratio (as decimal with 18 digits precision).
     * @param maintenanceMarginRatioD18 the maintenance margin ratio (as decimal with 18 digits precision).
     * @param liquidationRewardRatioD18 the liquidation reward ratio (as decimal with 18 digits precision).
     * @param maxLiquidationLimitAccumulationMultiplier the max liquidation limit accumulation multiplier.
     * @param maxSecondsInLiquidationWindow the max seconds in liquidation window (used together with the acc multiplier to get max liquidation per window).
     * @param minimumPositionMargin the minimum position margin.
     */
    function setLiquidationParameters(
        uint128 marketId,
        uint256 initialMarginRatioD18,
        uint256 maintenanceMarginRatioD18,
        uint256 liquidationRewardRatioD18,
        uint256 maxLiquidationLimitAccumulationMultiplier,
        uint256 maxSecondsInLiquidationWindow,
        uint256 minimumPositionMargin
    ) external;

    /**
     * @notice Set the max size of an specific market with this function.
     * @dev This controls the maximum open interest a market can have on either side (Long | Short). So the total Open Interest (with zero skew) for a market can be up to max market size * 2.
     * @param marketId id of the market to set the max market value.
     * @param maxMarketSize the max market size in market asset units.
     */
    function setMaxMarketSize(uint128 marketId, uint256 maxMarketSize) external;

    /**
     * @notice Set the locked OI Ratio for a market with this function.
     * @param marketId id of the market to set locked OI ratio.
     * @param lockedOiRatioD18 the locked OI ratio skew scale (as decimal with 18 digits precision).
     */
    function setLockedOiRatio(uint128 marketId, uint256 lockedOiRatioD18) external;

    /**
     * @notice Enable or disable a settlement strategy for a market with this function.
     * @param marketId id of the market.
     * @param strategyId the specific strategy.
     * @param enabled whether the strategy is enabled or disabled.
     */
    function setSettlementStrategyEnabled(
        uint128 marketId,
        uint256 strategyId,
        bool enabled
    ) external;

    /**
     * @notice Gets the settlement strategy details.
     * @param marketId id of the market.
     * @param strategyId id of the settlement strategy.
     * @return settlementStrategy strategy details (see SettlementStrategy.Data struct).
     */
    function getSettlementStrategy(
        uint128 marketId,
        uint256 strategyId
    ) external view returns (SettlementStrategy.Data memory settlementStrategy);

    /**
     * @notice Gets liquidation parameters details of a market.
     * @param marketId id of the market.
     * @return initialMarginRatioD18 the initial margin ratio (as decimal with 18 digits precision).
     * @return maintenanceMarginRatioD18 the maintenance margin ratio (as decimal with 18 digits precision).
     * @return liquidationRewardRatioD18 the liquidation reward ratio (as decimal with 18 digits precision).
     * @return maxLiquidationLimitAccumulationMultiplier the max liquidation limit accumulation multiplier.
     * @return maxSecondsInLiquidationWindow the max seconds in liquidation window (used together with the acc multiplier to get max liquidation per window).
     */
    function getLiquidationParameters(
        uint128 marketId
    )
        external
        view
        returns (
            uint256 initialMarginRatioD18,
            uint256 maintenanceMarginRatioD18,
            uint256 liquidationRewardRatioD18,
            uint256 maxLiquidationLimitAccumulationMultiplier,
            uint256 maxSecondsInLiquidationWindow
        );

    /**
     * @notice Gets funding parameters of a market.
     * @param marketId id of the market.
     * @return skewScale the skew scale.
     * @return maxFundingVelocity the max funding velocity.
     */
    function getFundingParameters(
        uint128 marketId
    ) external view returns (uint256 skewScale, uint256 maxFundingVelocity);

    /**
     * @notice Gets the max size of an specific market.
     * @param marketId id of the market.
     * @return maxMarketSize the max market size in market asset units.
     */
    function getMaxMarketSize(uint128 marketId) external view returns (uint256 maxMarketSize);

    /**
     * @notice Gets the order fees of a market.
     * @param marketId id of the market.
     * @return makerFeeRatio the maker fee ratio.
     * @return takerFeeRatio the taker fee ratio.
     */
    function getOrderFees(
        uint128 marketId
    ) external view returns (uint256 makerFeeRatio, uint256 takerFeeRatio);

    /**
     * @notice Gets the locked OI ratio of a market.
     * @param marketId id of the market.
     * @return lockedOiRatioD18 the locked OI ratio skew scale (as decimal with 18 digits precision).
     */
    function getLockedOiRatioD18(uint128 marketId) external view returns (uint256 lockedOiRatioD18);
}
