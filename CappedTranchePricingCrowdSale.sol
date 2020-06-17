pragma solidity >=0.5.11;
import "./CrowdSale.sol";
import "./CappedFundingStrategy.sol";


contract CappedTranchePricingCrowdSale is CrowdSale, CappedFundingStrategy {

    constructor (uint256 _startTime, uint256 _endTime, uint256 _weiTokenPrice, uint256 _etherInvestmentObjective) {
        TranchePricingCrowdsale(_startTime, _endTime,  _etherInvestmentObjective);
    }

    function createFundingLimitStrategy() internal returns (FundingLimitStrategy) {
        return new CappedFundingStrategy
    }

}