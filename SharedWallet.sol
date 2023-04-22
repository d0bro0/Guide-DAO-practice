//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SharedWallet is Ownable {

  struct User{
    string name;
    uint limit;
    bool is_admin;
  }
  mapping(address => User) public members;

  function isOwner() internal view returns(bool) {
    return owner() == _msgSender();
  }
    
  modifier ownerOrWithinLimits(uint _amount) {
    require(isOwner() || members[_msgSender()].is_admin || members[_msgSender()].limit >= _amount, "You are not allowed to perform this operation!");
    _;
  }
    
  function addLimit(address _member, uint _limit) public onlyOwner {
    members[_member] = User({name: "user", limit: _limit, is_admin: false});
  }
    
  function deduceFromLimit(address _member, uint _amount) internal {
    members[_member].limit -= _amount;
  }
    
  function renounceOwnership() override public view onlyOwner {
    revert("Can't renounce!");
  }
}
