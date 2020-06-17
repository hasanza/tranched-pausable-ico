pragma solidity ^0.5.11;
import "./SimpleCoin.sol";
//Child contract Acquires public and internal state variables and functions from the parent contract
//multiple inheritance happening here
contract ReleasableSimpleCoin is SimpleCoin, Pausable, Ownable {
    //2 main relationships b/w contracts:
 //1. Generalization = contract is inherited from a more general contract 
 //2. Dependency = A state variable is an instance of another contract 
 //beleow are new variables not found in father contract; these are peculiar to this contract
 
 //every instance of this contract has a check of whether the coins have been released or not
    bool public released = false; 

//if released becomes true, 
    modifier isReleased() {
        if(!released) {
            revert();
        }

        _;
    }

    constructor (uint256 _initialSupply) public {
        //instantiating SimpleCoin using base constructor i.e. father contract's constructor with no. of initial tokens
        SimpleCoin(_initialSupply);
    }

    //changes released state variable to true i.e. invester will gain ability to transfer tokens stored against thier address
    function release() onlyOwner public {
        released = true;
    }
    //By using same name as of a fucntion of father contract, we are overriding it. To use the original function, 
    //we need to use 'super' super.originalContractName(args)
    function transfer(address _to, uint256 _amount) isReleased public {
        //using func of inherited contract with own params.
        //use super to access inherited functions/ variables
        
        super.transfer(_to, _amount);
    }

    //func for allocated funds, overrides parent's func. has release check
    function transferFrom(address _from, address _to, uint256 _amount) isReleased public returns (bool) {
    //overriding func then calling it again but inside new func with isReleased modifier
    //calling original func but it is constrained by is released modifier   
        super.transferFrom(_from, _to, _amount);
    }


} 