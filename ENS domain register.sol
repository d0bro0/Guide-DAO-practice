// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MyFirstContract{
    address public owner;
    uint public yearPrice;
    uint public coefficient;
    mapping(string => User) public ENS;
    

    constructor()  {
        owner = msg.sender;
    }

    modifier ownerRequired() {
        require(msg.sender == owner, "Owner required");
        _;
    }

    struct User{
        address addr;
        uint timestamp;
        uint price;
        uint registerPeriod;
    }

    function setPrice(uint ETH_price) public ownerRequired{
        yearPrice = ETH_price*10**18;
    }

    function setCoefficient( uint _coefficient) public ownerRequired{
        coefficient = _coefficient;
    }

    function registerENS(string memory _ENS_name, uint _registerPeriod) public payable{
        require(_registerPeriod >= 1 && _registerPeriod <= 10);
        require(msg.value == _registerPeriod * yearPrice, "value = time*price");
        require(_registeredENS(_ENS_name) == false, "Already exist");

        ENS[_ENS_name] = User(msg.sender, block.timestamp, msg.value, _registerPeriod);
       
    }

    function priceCalculation(uint newPeriod, uint extendPeriod) external view returns(uint buyENS, uint extendENS) {
        uint _buyENS = newPeriod * yearPrice;
        uint _extendENS = extendPeriod * yearPrice - (yearPrice*coefficient/100)* extendPeriod; 
        return (_buyENS, _extendENS);
    }

    function _registeredENS(string memory _ENS_name) internal view returns(bool) {
        uint registeredTime = ENS[_ENS_name].registerPeriod;
        uint leftDuration = registeredTime*31556926 - ENS[_ENS_name].timestamp;
        if (registeredTime != 0 || leftDuration > 0) {
            return true;
        }
    }

    function domainExtension(string memory _ENS, uint _newPeriod) public payable{
        require(_registeredENS(_ENS) == true, "Haven't registered");
        require(msg.value == _newPeriod * yearPrice - (yearPrice*coefficient/100)* _newPeriod);
        ENS[_ENS] = User(msg.sender, block.timestamp, msg.value, _newPeriod);
    }

    function withdrawAllMoney(address payable _to) public ownerRequired{
        uint balanceToSend = address(this).balance;
        
        _to.transfer(balanceToSend);
    }

}
