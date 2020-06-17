pragma solidity >=0.5.11; 

import "./CrowdSale.sol";
//as quantity of remaining tokens enters certain tranches, their price in ether decreases
//this is a separate crowdsale contract which uses the first one
contract TranchePricingCrowdsale is CrowdSale{
    
    struct Tranche {
        //upper bound until tranche limit ends e.g. 3000 tokens
        uint256 weiHeightLimit;
        //price of tokens until limit ends
        uint256 weiTokenPrice;
    }

    mapping (uint256 => Tranche) public tranceStructure;
    //price will be calculated according to this. 
    uint256 public currentTrancheLevel;

//no need to rewrite code, just use base contract and write only additional code
    constructor (uint256 _startTime, uint256 _endTime, uint256 _weiTokenPrice, uint256 _etherInvestmentObjective) {
        CrowdSale(uint256 _startTime, uint256 _endTime, uint256 _weiTokenPrice, uint256 _etherInvestmentObjective) payable public {
           //token price is according to investment of individual investor
           //if he invests at most 3000, then he gets 3000/0.002 tokens 
            trancheStructure[0] = Tranche(3000 ether, 0.002 ether);
            trancheStructure[1] = Tranche(10000 ether, 0.003 ether);
            trancheStructure[2] = Tranche(15000 ether, 0.004 ether);
            trancheStructure[3] = Tranche(1000000000 ether, 0.005 ether);

            currentTrancheLevel = 0;
        }
    }

    function calculateNumberOfTokens(uint256 _investment) internal returns (uint256) {
        //changes the weiTokenPrice.
        updateCurrentTrancheAndPrice();
        return _investment/ weiTokenPrice;
    }

//calculates tokenprice for indivudial investor. at what rate to give him tokens?
    function updateCurrentTrancheAndPrice () internal {
        uint256 i = currentTrancheLevel;
    //investment is received in tokens
    //if tranche limite less than investment of investor, increase tranche level
        while (trancheStructure[i].weiHeightLimit < investmentReceived) {
            i++;
        }
        currentTrancheLevel = i;
        //current token price = the price of current tranche.
        //tranche downgrades as more investment is received
        weiTokenPrice = trancheStructure[currentTrancheLevel].weiTokenPrice;
    }
}