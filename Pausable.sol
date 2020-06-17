pragma solidity ^0.5.11; 

contract Pausable is Ownable{
    //pauses inheriting contract at owner's will

    //the pause state. 
    bool public paused = false;

    //the state must be unpaused for the modified func to be callable
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused, ("error message"));
        _;
    }

    function pause () public onlyOwner whenNotPaused {
        paused = true;
    }

    function unpause () public onlyOwner whenPaused {
        paused = false;
    }
}