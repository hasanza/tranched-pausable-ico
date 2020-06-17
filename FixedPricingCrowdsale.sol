pragma solidity >0.5.11;
import "./CrowdSale.sol";

//this contract uses fixed price using declared in crowdsale.col
//so crowdsale has now become an abstract func which other contracts use
contract FixedPricingCrowdsale is CrowdSale {
    //feeds data to
    constructor (uint256 _startTime, uint256 _endTime, uint256 _weiTokenPrice, uint256 _etherInvestmentObjective, uint256 _fundingCap) {
        //passing data to deployed CrowdSale contract to create an instance of it based on this data
        //, we will be using a lot of its functionality
        CrowdSale(_startTime, _endTime, _weiTokenPrice, _etherInvestmentObjective);
    }
}

function calculateNumberOfTokens(uint _investment) internal returns (uint256) {
    return investment / weiTokenPrice;
}