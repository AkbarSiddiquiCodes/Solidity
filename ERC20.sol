// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import "./Ownable.sol";

contract ERC20 is Ownable (msg.sender) {
    uint256 private totalSupply;
    string private name;
    string private symbol;

    mapping (address => uint256)  private balances;                             // balances[address] returns uint256
    mapping (address => mapping(address => uint256))  private allowed;      // allowed[address][address] returns uint256


    constructor (string memory _name, string memory _symbol)  {
        name = _name;
        symbol = _symbol;
    }
    function getTokenSpecifications() public onlyOwner view returns (address, string memory, string memory, uint256) {
        return (getOwner(), name, symbol, totalSupply);
    }

    function balanceOf (address _address) public view virtual returns (uint256){
        return balances[_address];
    }
    function transfer (address _to,  uint256 _amount)  public virtual returns (bool)  {
        require (_to != address(0),"Destination can't be 0");

        uint256 fromBalance = balances[msg.sender];
        require (fromBalance >= _amount, "Balance too low");

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        return(true);
    }
 
    function allowance (address _owner,  address _spender) public view virtual returns (uint256){
        return allowed[_owner][_spender];
    }

    function approve (address _owner,address _spender,  uint256 _amount)  public virtual{
        allowed[_owner][_spender] = _amount;
    }

    function spendAllowance (address _owner, address _spender, uint256 _amount) public  virtual {
        require (allowance(_owner, _spender ) >= _amount,  "ERC20: approve amount is insufficient" );
        uint256 temp = allowance(_owner, _spender );
        temp -= _amount;
        approve (_owner,_spender, temp);
    }
    
    function transferFrom (address _from, address _to, uint256 _amount) public virtual returns (bool)  {
        require (_from != address(0),"Destination can't be 0");
        require (_to != address(0),"Destination can't be 0");
        uint256 fromBalance = balances[_from];
        require (fromBalance >= _amount, "Balance too low");
        balances[_from] -= _amount;
        balances[_to] += _amount;
        spendAllowance (_from,msg.sender, _amount);       //This checking is important for transferfrom
        return (true);
    }

    function mint (uint256 _amount) public onlyOwner virtual {
        totalSupply += _amount;
        balances[msg.sender] += _amount;
    }
}

