//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

abstract contract ERC1155{
    string private name;
    string private symbol;
    uint8 private constant decimals = 2;
    
    constructor() {
        name = "Akbar";
        symbol = "AKR";
    }
    mapping (address owner => mapping (uint256 tokenId => uint256 amount)) private balances; 
    mapping (uint256 tokenId => address owner)private owners;
    mapping (uint256 tokenId => string hostAddress) tokenURI;
    mapping (address owner => mapping (address sender => mapping (uint256 tokenId => uint256 amount)))tokenOperator;

    function getInfo() public view returns (string memory, string memory) {
        return (name, symbol);
    }
    function mint(address _owner, uint256 _tokenId,uint256 _amount,string memory _tokenURI) internal {
        require (balances[_owner][_tokenId] == 0, "Already minted!");
        require (_owner != address(0), "Invalid address");
        balances[_owner][_tokenId]= _amount * 10 ** decimals;
        tokenURI[_tokenId] = _tokenURI;
        
    }
    function transfer(uint256 _tokenId,uint256 _amount,address _destination)public {
        require (_destination != address(0), "Invalid address");
        require (balances[msg.sender][_tokenId] >= _amount, "Insufficient balance");
        balances[msg.sender][_tokenId] -= _amount;
        balances[_destination][_tokenId]+=_amount;
    }
    function balanceOf(address _account,uint256 _tokenId) public view returns (uint256){
        return(balances[_account][_tokenId]);
    }
    function approveOperator (address _operator, uint256 _tokenId, uint256 _amount) public {
        require (balances[msg.sender][_tokenId] >= _amount, "You should generate token with this tokenId");
        require (_operator != address(0),"Invalid address");
        tokenOperator[msg.sender][_operator][_tokenId] = _amount;
    }
    function removeOperator (address _operator, uint256 _tokenId) public {
        require (_operator != address(0),"Invalid address");
        tokenOperator[msg.sender][_operator][_tokenId] = 0;
    }
    function getOperator (address _owner, address _operator, uint256 _tokenId) public view returns (uint256){
        return tokenOperator[_owner][_operator][_tokenId];
    }
    function transferFrom (address _owner, address _to, uint256 _tokenId, uint256 _amount) public {
        require (_owner != address(0),"Invalid address");
        require (_to != address(0),"Invalid address");
        require (_amount <= balances[_owner][_tokenId],"Insufficient balance");
        if(_owner != msg.sender){
            require (_amount <= tokenOperator[_owner][msg.sender][_tokenId],"Access denied!");
            uint256 amount = getOperator(_owner, msg.sender, _tokenId);
            amount -= _amount;
            tokenOperator[_owner][msg.sender][_tokenId] = amount;  
        }
        balances[_owner][_tokenId] -= _amount;
        balances[_to][_tokenId] += _amount;
    }
}