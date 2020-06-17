pragma solidity >=0.5.11;
import "./ReleasableSimpleCoin.sol";
//inheriting from Ownable, now we can use its public and internal states variables and functions
//we will now use the onlyOwner modifier w/o redefiing it here
import "./Ownable.sol";

contract CrowdSale is Ownable {
    uint public startTime;
    uint public endTime;
    //price in ether of one token
    uint public weiTokenPrice;
    //minimum ether needed before tokens are allotted to investors
    uint public weiInvestmentObjective;

    //index of investors => investments. So a mapping
    mapping (address => uint256) public investmentAmountOf;
    //ether received from an address/ investor
    uint public investmentReceived;
    //ether refunded to address that asked for it
    uint public investmentRefunded;

    //if the crowdsale is finalized
    bool public isFinalised;
    bool public isRefundingAllowed;      

    //onlyOwner modifier sets this state variable to contract sender
    address public owner;
    //created a variable to hold reference to a ReleasableSimpleCoin instance
    ReleasableSimpleCoin public crowdsaleToken;
    //create a variable of type FLS to hold its instance
    FundingLimitStrategy internal fundingLimitStrategy;

    constructor (uint256 _startTime, uint256 _endTime, uint256 _weiTokenPrice, uint256 _etherInvestmentObjective) public {
        require(_startTime >= now);
        require(_endTime >=_startTime);
        require(_weiTokenPrice != 0);
        require(_etherInvestmentObjective !=0);

        startTime = _startTime;
        endTime = _endTime;
        weiTokenPrice = _weiTokenPrice;
        //converting investment objective from eth to wei. Coming from larger unit to smaller thus multiplying 
        weiInvestmentObjective = _etherInvestmentObjective * 1000000000000000000;
    //Create new simpleCoin and assign it to variable of that type
        crowdsaleToken = new ReleasableSimpleCoin(0);
        isFinalised = false;
        isRefundingAllowed = false;
        //owner = msg.sender;
        //stores ref to instance of FLS contract which has bool check
        //for when total investment is in limit. 
        fundingLimitStrategy = createFundingLimitStrategy();
    }
    //just a declaration. Creates and returns FLS instance. The inheriting contract can choose from a range of Fundinglimitstrategies
    function createFundingLimitStrategy() internal returns (FundingLimitStrategy);


    event LogInvestment(address indexed investor, uint256 value);
    event LogTokenAssignment(address indexed investor, uint256 numTokens);

    //accepts ether and converts it into tokens which are releasd only if investmentObjective is met or else refunded
    function invest() public payable {
        require(isValidInvestment(msg.value));

        address payable investor = msg.sender;
        uint investment = msg.value;

        investmentAmountOf[investor] += investment;
        investmentReceived += investment;

        assignTokens(investor, investment);
        emit LogInvestment(investor, investment);
    }

    function isValidInvestment(uint256 _investment) internal view returns (bool){
        //is true if investment is not zero
        bool nonZeroInvestment = _investment !=0;
        //is true if investment was made within the crowdsale period
        bool withinCrowdsalePeriod = true;//now >= startTime && now <= endTime;
//checks if inv is 0, within crowdsale period and has not hit the cap.
        return nonZeroInvestment && withinCrowdsalePeriod
            && fundingLimitStrategy.isFullInvestmentWithinLimit(_investment, investmentReceived);
    }

    function assignTokens(address _beneficiary, uint256 _investment) internal {
        //convert ether to tokens as per set exchange rate. func returns no. of tokenss
        uint _numberOfTokens = calculateNumberOfTokens(_investment);

        //create tokens as per the no. of tokens returned by above func for said beneficiary
        crowdsaleToken.mint(_beneficiary, _numberOfTokens);
    }
    

    //this func is called by assignToken func. It returns the no. of tokenns that are to be allotted
    //to that investor. No. of tokens depends on token price we set. Currently fixed
    //* We only declare the func here, not implement it because we want tranche pricin. 
    //We implement it in contracts that derive this. 
    //This func has made this contract abstract

    function calculateNumberOfTokens(uint256 _investment) internal returns (uint256); //{
        //invetment is in ether, we are calculating the no. of tokens allotted to investors
        // return _investment / weiTokenPrice;
    //}

    function finalise() onlyOwner public {
        //prevents callign finalise on a finalised contract i.e. if isFinalised is true
        //  revert() undoes all changes made to the state in the current call (and all its sub-calls) and also flag an error to the caller
        if (isFinalised) revert("Crowd sale already finalised");
    //assigns true or false dpending on condition being met
        bool isCrowdsaleComplete = true;//now > endTime;
        bool investmentObjectiveMet = investmentReceived >= weiInvestmentObjective;

        if(isCrowdsaleComplete) {
            if (investmentObjectiveMet) {
                crowdsaleToken.release();
            } else {
                isRefundingAllowed = true;
            }
            isFinalised = true;
        }
    }
    event Refund(address investor, uint256 value);
    function refund() public {
        if(!isRefundingAllowed) {
            revert();
        }
        address investor = msg.sender;
        uint256 investment = investmentAmountOf[investor];
        if (investment == 0) {revert();}
        investmentAmountOf[investor] = 0;
        investmentRefunded += investment;
        emit Refund(investor, investment);
    //if successful, investor.transfer() returns true, if its false that maens an error occured. in that case, state is reverted
        if(!investor.send(investment)) {
            revert();
        }
    } 

    //if investmentObjective met, finalize releases tokens to investors. Token bonus depending on total ivnstment may also be issued to devs.
    //if objective not met, contract moves into refunding state. Investors can call function to get investrment back
    //tokens must stay locked down before the are released to owners. but simplecoin doesnt have such locks. So we use ReleaseableSimplecoin
    //Releasable's funcs like transfer and transferFrom wont work unless token has been released
}