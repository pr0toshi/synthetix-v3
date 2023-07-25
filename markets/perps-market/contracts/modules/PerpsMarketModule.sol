//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {PerpsMarket} from "../storage/PerpsMarket.sol";
import {PerpsMarketConfiguration} from "../storage/PerpsMarketConfiguration.sol";
import {PerpsPrice} from "../storage/PerpsPrice.sol";
import {AsyncOrder} from "../storage/AsyncOrder.sol";
import {IPerpsMarketModule} from "../interfaces/IPerpsMarketModule.sol";
import {AddressError} from "@synthetixio/core-contracts/contracts/errors/AddressError.sol";

contract PerpsMarketModule is IPerpsMarketModule {
    using PerpsMarket for PerpsMarket.Data;
    using AsyncOrder for AsyncOrder.Data;

    function metadata(
        uint128 marketId
    ) external view override returns (string memory name, string memory symbol) {
        PerpsMarket.Data storage market = PerpsMarket.load(marketId);
        return (market.name, market.symbol);
    }

    function skew(uint128 marketId) external view override returns (int256) {
        return PerpsMarket.load(marketId).skew;
    }

    function size(uint128 marketId) external view override returns (uint256) {
        return PerpsMarket.load(marketId).size;
    }

    function maxOpenInterest(uint128 marketId) external view override returns (uint256) {
        return PerpsMarketConfiguration.load(marketId).maxMarketSize;
    }

    function currentFundingRate(uint128 marketId) external view override returns (int) {
        return PerpsMarket.load(marketId).currentFundingRate();
    }

    function currentFundingVelocity(uint128 marketId) external view override returns (int) {
        return PerpsMarket.load(marketId).currentFundingVelocity();
    }

    function indexPrice(uint128 marketId) external view override returns (uint) {
        return PerpsPrice.getCurrentPrice(marketId);
    }

    function fillPrice(
        uint128 marketId,
        int orderSize,
        uint price
    ) external view override returns (uint) {
        return
            AsyncOrder.calculateFillPrice(
                PerpsMarket.load(marketId).skew,
                PerpsMarketConfiguration.load(marketId).skewScale,
                orderSize,
                price
            );
    }

    function getMarketSummary(
        uint128 marketId
    ) external view override returns (MarketSummary memory summary) {
        PerpsMarket.Data storage market = PerpsMarket.load(marketId);
        return
            MarketSummary({
                skew: market.skew,
                size: market.size,
                maxOpenInterest: this.maxOpenInterest(marketId),
                currentFundingRate: market.currentFundingRate(),
                currentFundingVelocity: market.currentFundingVelocity(),
                indexPrice: this.indexPrice(marketId)
            });
    }
}
