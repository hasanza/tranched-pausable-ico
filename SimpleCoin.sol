pragma solidity >=0.5.11;
import "./Ownable.sol";

contract SimpleCoin is Ownable{
    //create a hash map. An int (value) for every address type (key) 
    mapping (address => uint256) public coinBalance;
    //event. Can be triggered upon a tarnsfer
    event Transfer(address indexed from, address indexed to, uint256);

    constructor (uint256 _initialSupply) public {
        //constructor gives initial supply as param to mint func
        address owner = msg.sender;
        //in the public hash map 'coinBalance', sets the value of first arg to sencond arg
        mint (owner, _initialSupply);
    }

    //no need to define modifier here after inheriting Ownable
    // modifier onlyOwner {
    //     //enforces onlyOwner requirement to a function; only the owner address may call it
    //     require (msg.sender == owner);
    //     _;
    // }
//creates initial money supply and sends it all the to recipient, in this case owner
    function mint (address _recipient, uint256 _mintedAmount) onlyOwner public {
        coinBalance[_recipient] = _mintedAmount;
        emit Transfer (owner, _recipient, _mintedAmount);
    }
//the caller can transfer money to an account. So, msg.sender will transfer arg2 to arg 1
    function transfer (address _to, uint256 _amount) public {
        //sender must have enough...
        require(coinBalance[msg.sender] > _amount);
        //recipient's balance must increase or stay the same at least, after receiving amount...
        require(coinBalance[_to] + _amount >= coinBalance[_to]);
        //reduce sender's balance by the amount sent.
        coinBalance[msg.sender] -= _amount;
        //increase recipient's balance by the amount sent
        coinBalance[_to] += _amount;
        //event emitted for logging purposes
        emit Transfer(msg.sender, _to, _amount);//https:www.youtube.com/watch?v=Q3TI27IN7X0&list=RDMMACU92JHNuyc&index=5
    }
        //implementing allowance with nested mapping
        //Allowing another accoint to transfer a fized amount to other accounts
        //map looks like this: mapName[address][address] = value; former address is allower, latter is allowed
        mapping (address => mapping (address => uint256)) public allowance;

    //allowance now made possible. Auth account(arg1) can now transfer authorizers(msg.sender, the one calling the func.) allowance (arg 2)
        function authorize (address _authorizedAccount, uint256 _allowance) public returns (bool success) {
            //setting value of second key, the authorised acc, to allowance
            allowance[msg.sender][_authorizedAccount] = _allowance;
            return true;
        }
    //implementing allowance transfer logic. arg1 is authoriser, arg2 is recipient
        function transferFrom (address _from, address _to, uint256 _amount) public returns (bool success) {
            //Receiver of auth funds is not null
            require (_to !=0x0);
            //the authorising account (key1) has enough funds to transfer
            require (coinBalance[_from] > _amount); 
            //the recipient's amount wont decrrease aafter transfer
            require (coinBalance[_to] + _amount >= coinBalance[_to]);
            //amount being transfered must be at most the allowed amount, i.e. the value of the second key (authorised acc.)
            //msg.sender is the authorised account, the second key
            require (_amount <= allowance[_from][msg.sender]);//amount must be at most the auth amount
            //Reduce Authorizers account by sent amount
            coinBalance[_from] -= _amount;
            //increases recipient's balance by amount
            coinBalance[_to] += _amount;
            //reduces the amount authorised to second key by amount.
            allowance[_from][msg.sender] -= _amount;//Reduces amount authorized to caller

            emit Transfer (_from, _to, _amount);

            return true;
        }
    //Implementing owners power to freeze accounts
    //every address(key), now has a bool value; if its true, that acc is frozen
        mapping (address => bool) public frozenAccount;
        event FrozenAccount (address target, bool frozen);
        //only owner may freeze accounts. Then we can check upon every transfer whether acc is frozen by contract owner
        function freezeAccount (address target, bool freeze) onlyOwner public {
            frozenAccount[target] = freeze;//adds target to list of frozen accounts
            emit FrozenAccount (target, freeze);
        }
}