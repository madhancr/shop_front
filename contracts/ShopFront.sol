pragma solidity ^0.4.6;

import "./Owned.sol";

contract ShopFront is Owned{
    
    struct Product {
        uint price;
        uint quantity;
        bool exists;
    }
    
    mapping (uint => Product) public products;
    mapping (address => bool) public admins;
    
    event LogNewProduct(address sender, uint id, uint price, uint qty);
    event LogAddStock(address sender, uint id, uint qty);
    event LogRemoveStock(address sender, uint id, uint qty);
    event LogChangePrice(address sender, uint id, uint price);
    event LogSoldProduct(address buyer, uint id, uint qty);
    event LogAddBalance(uint amount);
    event LogWithdrawal(uint amount);
    event LogAddAdmin(address admin);
    event LogRemoveAdmin(address admin);
    
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
        LogAddAdmin(admin);
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
        LogRemoveAdmin(admin);
        return true;
    }
    
    function deposit()
        public
        payable
        onlyOwner
        onlyAdmin // admins can handle returns  
    {
        LogAddBalance(msg.value);
    }
    
    function withdraw(uint amount)
        public
        onlyOwner
    {
        require(this.balance >= amount);
        msg.sender.transfer(amount);
        LogWithdrawal(amount);
    }
    
    /* Admin Functions */
    function addProduct(uint productId, uint price, uint quantity)
        public
        onlyAdmin
        returns (bool success)

    {
        require(quantity > 0);
        require(products[productId].exists == false);

        products[productId] = Product({
                            price: price,
                            quantity: quantity,
                            exists: true
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
        require(products[productId].exists);
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
        require(products[productId].exists);
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
        require(products[productId].exists);
        
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
        require(products[productId].exists);
        require(products[productId].quantity > qty);
        uint total = products[productId].price * qty;
        require(msg.value >= total);
        
        if (msg.value > total) {
            msg.sender.transfer(msg.value - total);
        }

        products[productId].quantity -= qty;
        LogSoldProduct(msg.sender, productId, qty);
        return true;
    }
    
    
}


