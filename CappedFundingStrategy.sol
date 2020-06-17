pragma solidity >0.5.11;
import "./FundingLimitStrategy.sol";

contract CappedFundingStrategy is FundingLimitStrategy {
    constructor(uint256 _fundingCap) public {
        require(_fundingCap > 0, ("error message!"));
        fundingCap = _fundingCap; 
    }

    //function inherited from abstract being implemented here

    function isFullInvestmentWithinLimit (uint256 _investment, uint256 _fullInvestmentReceived) public view returns (bool) {
        bool check = _fullInvestmentReceived + _investment <= fundingCap;
        return check;
    }

}