pragma solidity >=0.5.11;
//base congract for all funding limit strategies e.g. capped and unlimited
abstract FundingLimitStrategy {

    function isFullInvestmentWithinLimit(uint256 _investment, uint256 _fillInvestmentReceived) public view returns (bool);

}