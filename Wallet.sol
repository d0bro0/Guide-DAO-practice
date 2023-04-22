//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./SharedWallet.sol";

contract Wallet is SharedWallet {

  event MoneyWithdrawn(address indexed _to, uint _amount);
  event MoneyReceived(address indexed _from, uint _amount);
  event LimitChanged(address indexed _address, uint _oldlimit, uint _newlimit);
  
  function makeAdmin(address _admin) public onlyOwner{
    members[_admin].name = "admin";
    members[_admin].is_admin = true;
  }

  function revokeAdmin(address _admin) public onlyOwner{
    members[_admin].name = "user";
    members[_admin].is_admin = false;
  }
    
  function withdrawMoney(uint _amount) public ownerOrWithinLimits(_amount) {
    require(_amount <= address(this).balance, "Not enough funds to withdraw");
    uint _oldlimit = members[_msgSender()].limit;   

    if(!isOwner() && !members[_msgSender()].is_admin) { 
      deduceFromLimit(_msgSender(), _amount); 
    }

    emit LimitChanged(_msgSender(),_oldlimit,members[_msgSender()].limit);

        
    address payable _to = payable(_msgSender());
    _to.transfer(_amount);
        
    emit MoneyWithdrawn(_to, _amount);
  }

    
  function sendToContract(address _to) public payable {
    address payable to = payable(_to);
    to.transfer(msg.value);
        
    emit MoneyReceived(_msgSender(), msg.value);
  }
    
  function getBalance() public view returns(uint) {
    return address(this).balance;
  }


  function deleteMember(address _adr) public onlyOwner {
    delete members[_adr];
  }
    
  fallback() external payable {}
    
  receive() external payable { 
    emit MoneyReceived(_msgSender(), msg.value); 
  }
}
