pragma solidity ^0.4.8;
import "./FixedSupplyToken.sol";

contract AuctionToken is FixedSupplyToken {

    uint256 public buyPriceEnd;

    function AuctionToken(uint256 totalSupply,
    address _owner,
    string _symbol,
    string _name,
    uint256 _buyPriceStart,
    uint256 _buyPriceEnd,
    uint256 _sellPrice,
    uint256 _saleStart,
    uint256 _saleEnd) FixedSupplyToken (totalSupply, _owner, _symbol, _name, _buyPriceStart, _sellPrice, _saleStart, _saleEnd){
        /*if(_buyPriceStart > _buyPriceEnd) {
            throw;
        }*/
        buyPriceEnd = _buyPriceEnd;
    }

    function getBuyPrice() constant returns (uint) {
        uint currentPrice;
        uint passed;
        if(buyPrice < buyPriceEnd) {
            passed = now - saleStart;
            currentPrice = buyPrice + (((buyPriceEnd - buyPrice) * passed) / saleDuration);
        } else if (buyPrice > buyPriceEnd) {
            passed = now - saleStart;
            currentPrice = buyPrice - (((buyPrice - buyPriceEnd) * passed) / saleDuration);
        } else {
            currentPrice = buyPrice;
        }
        if(currentPrice <= 0){
            currentPrice = 1;
        }
        return currentPrice;
    }

    function getDetails() constant returns (address _owner,
                                            string _name,
                                            string _symbol,
                                            uint256 totalSupply,
                                            uint256 _creationDate,
                                            uint256 _buyPriceStart,
                                            uint256 _buyPriceEnd,
                                            uint256 _sellPrice,
                                            uint256 _saleStart,
                                            uint256 _saleEnd){
        return (owner, name, symbol, _totalSupply, creationDate, buyPrice, buyPriceEnd, sellPrice, saleStart, saleEnd);
    }
    function buy() payable returns (uint amount){
        amount = msg.value / getBuyPrice();                     // calculates the amount
        if (balances[owner] < amount || amount <= 0) throw;     // checks if it has enough to sell
        balances[msg.sender] += amount;                   // adds the amount to buyer's balance
        balances[owner] -= amount;                         // subtracts amount from seller's balance
        Transfer(owner, msg.sender, amount, balances[owner]);                // execute an event reflecting the change
        return amount;                                     // ends function and returns
    }

    function sell(uint amount) returns (uint256 revenue){
        if (balances[msg.sender] < amount ) throw;        // checks if the sender has enough to sell
        balances[owner] += amount;                         // adds the amount to owner's balance
        balances[msg.sender] -= amount;                   // subtracts the amount from seller's balance
        revenue = amount * sellPrice;
        if (!msg.sender.send(revenue)) {                   // sends ether to the seller: it's important
            throw;                                         // to do owner last to prevent recursion attacks
        } else {
            Transfer(msg.sender, owner, amount, balances[owner]);             // executes an event reflecting on the change
            return revenue;                                 // ends function and returns
        }
    }
}
