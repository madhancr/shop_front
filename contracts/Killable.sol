pragma solidity ^0.4.6;
import "./Owned.sol";

contract Killable is Owned {

    event LogKilled(address sender);

    function kill() 
    onlyOwner
    {
        LogKilled(msg.sender);
        selfdestruct(owner);
    }

}