var shopFront = artifacts.require("./ShopFront.sol");

const Promise = require('bluebird');
Promise.promisifyAll(web3.eth, {suffix: "Promise"});
Promise.promisifyAll(web3.version, {suffix: "Promise"});

const expectException = require("./utils.js").expectedExceptionPromise;
const expectThrow = require("./utils.js").expectThrow;


contract('ShopFront', function(accounts) {
  var owner = accounts[0];
  var admin = accounts[1]
  var user = accounts[2];
  var shopfront;


  beforeEach(function() {
    return shopFront.new({from: owner})
      .then(instance => {
        shopfront = instance;
      });
  });

  it("should add an admin", function() {
    return shopfront.addAdmin(admin, {from: owner})
      .then(txObject => {
        //console.log(txObject);
        return shopfront.admins.call(admin);
      })
      .then(_exist => {
        assert.strictEqual(_exist, true, "Admin not added");

      })
  });


  // product management
  describe("add product tests", function() {
    var product = {id: 1, price: 15, quantity: 10};

    it("should add a product", function() {
      shopfront.addAdmin(admin, {from: owner})
       .then(txObject => {
         return shopfront.addProduct(product.id, product.price, product.quantity, {from: admin})
        })
        .then(txObject => {
          //console.log(txObject);
          return shopfront.products.call(product.id);
        })
        .then(_product => {
          var [_price, _quantity, _exists] = _product;
           //console.log(_product);
          assert.strictEqual(_price.toNumber(), product.price, "Price is wrong");
          assert.strictEqual(_quantity.toNumber(), product.quantity, "Quantity is wrong");
          assert.strictEqual(_exists, true, "Product is not marked as existing");
        })
    });



    it("should only let the owner add product", async function() {
      await expectThrow(
        shopfront.addProduct(product.id, product.price, product.quantity, {from: user})
      );
    });

    it("should fail if you add a product with zero quantity", async function() {
      await expectThrow(shopfront.addProduct(product.id, product.price, 0, {from: admin}));
    });

  });

  describe("tests with existing product", function() {
    var product = {id: 10, price: 15, quantity: 1};

    beforeEach(function() {
      shopfront.addAdmin(admin, {from: owner})
      .then(txObject => {
        return shopfront.addProduct(product.id, product.price, product.quantity, {from: admin})
       })
      });

    it("should not be able to add an existing product", async function() {
      await expectThrow(shopfront.addProduct(product.id, product.price, product.quantity,
        {from: admin})
      );
    });

    it("should be able to add stock", function() {
      let restock = 5;
      return shopfront.addStock(product.id, restock, {from: admin})
        .then(txObject => {
          return shopfront.products.call(product.id);
        })
        .then(_product => {
          assert.strictEqual(_product[1].toNumber(), product.quantity + restock, "Product quantity is wrong");
        });
    });
    it("should let a user buy a product", function() {
      var qty = 2;
      return shopfront.buyProduct(product.id, qty, {from: user, value: product.price * qty})
        .then(txObject => {
          return shopfront.products.call(product.id);
        })
        .then(_product => {
          let quantity = _product[1];
          assert.strictEqual(quantity.toNumber(), product.quantity - qty, "Quantity left is wrong")
          return shopfront.balance.call();
        })
        .then(_balance => {
          assert.strictEqual(_balance.toNumber(), product.price * qty, "Balance is wrong after buy");
        });
    });

    it("should only let the admin add stock", async function() {
      await expectThrow(shopfront.addStock(product.id, 5, {from: user}));
    });

    it("should not be able to add zero stock", async function() {
      await expectThrow(shopfront.addStock(product.id, 0, {from: admin}));
    });


  });



  // intialization tests
  it("should be owned by the owner", function() {
    return shopfront.owner({from: owner})
      .then(_owner => {
        assert.strictEqual(_owner, owner, "Contract is not owned by owner");
      })
  });


});


