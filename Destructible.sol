pragma solidity >=0.5.11;
import "./Ownable.sol";

contract Destructible is Ownable{
    constructor () public payable {}

    function destroyAndSend (address payable _recipient) public onlyOwner{
        selfdestruct(_recipient);
        } 
}