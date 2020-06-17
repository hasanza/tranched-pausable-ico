pragma solidity >=0.5.11;

//a proxy abstract contract for SafeMath.
//we use abstrat contract to ensure type safety i.e. we dont accdentally send
//wrong type params when calling SafeMath methods with call();
abstract SafeMathProxy {
    function mul(uint256 a, uint256 b) public pure returns (uint256);
    function div(uint256 a, uint256 b) public pure returns (uint256);
    function sub(uint256 a, uint256 b) public pure returns (uint256);
    function add(uint256 a, uint256 b) public pure returns (uint256);
}

contract Calculator {
    //know that SafeMath lib is already deployed on a particular address
    //we aim to use its pure functionality
    //a variable to hold ref to SafeMathProxy type. The contract instance referred to will have those functions implementations
    SafeMathProxy safeMath;
    constructor (address _libararyAddress) public {
        require (_libraryAddress != 0x0);
        /*we store ref to already deployed SafeMath in SafeMathProxy type variable because latter, an abstract, has the same functionality as the actual
        SafeMath lib. Using a lib via abstract ensures type safety and we can only use the functionality we want, that we have defined in
        our abstract */
        safeMath = SafeMathProxy(_libraryAddress);
    }

    function calculateTheta(uint256 a, uint256 b) returns (uint256) {
        //calls to deployed SafeMath lib whose reference is held by a variable of 
        //type SafeMathProxy; this contracts declares the functionality we need whose
        //implementation is in the actual SafeMath lib. 
        uint256 delta = safeMath.sub(a, b);               
        uint256 beta = safeMath.add(delta, 1000000);                                      
        uint256 theta = safeMath.mul(beta, b);            

        uint256 result = safeMath.div(theta, a);          
        
        return result;
    }
}

/*1. deploye your lib. Copy its address 
2. Paste its address into calculator constructor and deploy Calculator
3/ Calculater contract is instantiated, now u can call calculateTheta and itll work
4. calls to SafeMath's func are made thru Proxy instance
**when lib func is called, its code is executed in context of msg.sender i.e. 
the callign contract becayse it is invoked thru DELEGATECALL and not thru CALL opcode
. When funcs are used, only calling contract access storage directly,

Context here means the contract whose storgage will be used/ manipulated/ by the called contract/ library 
if A does CALL on B, code runs in context of B, B's storage is used. 
if A does CALLCODE on B, B's code runs in A's context, A's storage is used.
if A invokes B and B does DELEGATECALL on E, msg.sender and msg.value for E is what it was for B i.e. A
DELEGATECALL is like CALLCODE but its used by the intermediary contract to relay the CALLCODE request from caller contract to called contract
*/