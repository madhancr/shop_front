pragma solidity ^0.4.6;

contract Owned {
    
    address public owner;

    event LogTransferOwnership(address sender, address newOwner);

    function Owned() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }
    
 
    
    function transferOwnership (address newOwner)
    onlyOwner
    {
        require(newOwner != address(0));
        owner = newOwner;
        LogTransferOwnership(msg.sender, newOwner);
    }
    
}

