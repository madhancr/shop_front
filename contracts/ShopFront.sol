pragma solidity ^0.4.6;

import "./Owned.sol";
import "./Killable.sol";

contract ShopFront is Owned, Killable {
    
    struct Product {
        uint price;
        uint quantity;
    }
    
    mapping (uint => Product) public products;
    mapping (address => bool) public admins;
    
    event LogNewProduct(address sender, uint id, uint price, uint qty);
    event LogAddStock(address sender, uint id, uint qty);
    event LogRemoveStock(address sender, uint id, uint qty);
    event LogChangePrice(address sender, uint id, uint price);
    event LogSoldProduct(address sender, uint id, uint qty);
    event LogAddBalance(address sender, uint amount);
    event LogWithdrawal(address sender, uint amount);
    event LogAddAdmin(address sender, address admin);
    event LogRemoveAdmin(address sender, address admin);
    
    modifier onlyAdmin() {
        require(admins[msg.sender] == true);
        _;   
    }
    
    /* constructor */
    function ShopFront () {}
    
    /* owner functions */
    function addAdmin(address admin) 
        public 
        onlyOwner
        returns (bool success)
    {
        require(admins[admin] == false);
        admins[admin] = true;
        LogAddAdmin(msg.sender, admin);
        return true;
    }
    
    function removeAdmin(address admin) 
        public 
        onlyOwner
        returns (bool success)
    {
        require(admins[admin] == true);
        admins[admin] = false;
        delete admins[admin];
        LogRemoveAdmin(msg.sender, admin);
        return true;
    }
    
    function deposit()
        public
        payable
        onlyOwner
    {
        LogAddBalance(msg.sender, msg.value);
    }
    
    function withdraw(uint amount)
        public
        onlyOwner
    {
        require(this.balance >= amount);
        msg.sender.transfer(amount);
        LogWithdrawal(msg.sender, amount);
    }
    
    /* Admin Functions */
    function addProduct(uint productId, uint price, uint quantity)
        public
        onlyAdmin
        returns (bool success)

    {
        require(price > 0);
        require(quantity > 0);
        require(products[productId].price == 0); // product does not exist

        products[productId] = Product({
                            price: price,
                            quantity: quantity
                        });

        LogNewProduct(msg.sender, productId, price, quantity);
        return true;
    }

    function addStock(uint productId, uint _quantity)
        public
        onlyAdmin
        returns (bool success)
    {
        require(_quantity > 0);
        require(products[productId].price > 0); // product exists 
        products[productId].quantity += _quantity;
        LogAddStock(msg.sender, productId, _quantity);
        return true;
    }
    
    function removeStock(uint productId, uint _quantity)
        public
        onlyAdmin
        returns (bool success)

    {
        require(_quantity > 0);
        require(products[productId].price > 0); // product exists
        require(_quantity <= products[productId].quantity);
        
        products[productId].quantity -= _quantity;
        LogRemoveStock(msg.sender, productId, _quantity);
        return true;
    }
    
    function changePrice(uint productId, uint _price)
        public
        onlyAdmin
        returns (bool success)
    {
        require(products[productId].price > 0); // product exists
        
        products[productId].price = _price;
        LogChangePrice(msg.sender, productId, _price);
        return true;
    }
    
    /* user function */
    function buyProduct(uint productId, uint qty)
        public
        payable
        returns (bool success)
    {
        require(products[productId].price > 0); // product exists
        require(products[productId].quantity > qty);
        uint total = products[productId].price * qty;
        require(msg.value >= total);
        
        products[productId].quantity -= qty;
        LogSoldProduct(msg.sender, productId, qty);
        if (msg.value > total) {
            msg.sender.transfer(msg.value - total);
        }
        return true;
    }
    
    
}


