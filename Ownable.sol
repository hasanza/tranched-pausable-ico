//this contract has the ownership state and modifier
//prevents duplocation of isOwner modifier in both somplecoin and crowdsale
pragma solidity >0.5.11;

contract Ownable {
    address payable public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

//now we can remove owner state variable and onlyOwner midifer 
//from both contracts and inherit both from Ownable