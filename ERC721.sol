//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721Example is Ownable (msg.sender) {
   
    string private name;
    string private symbol;
   
    constructor(string memory _name,string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
   
    mapping (uint256 => address)private owners;
    mapping (address => uint256) private balances;     
    mapping (uint256 _tokenId => address)tokenApproval;   
    mapping (uint256 => string)tokenURI;            // tokenURI[uint256] gets string
    mapping (address origin=> mapping (address operator=> bool))tokenOperator;

    event TokenMinted(address indexed destination, uint256 tokenId, string tokenURI);
    event TokenTransferred (address indexed origin, uint256 tokenId, address indexed destination); 

    function getInfo() public view returns (string memory, string memory) {
        return (name, symbol);
    }
    
    function mint(address _destination, uint256 _tokenId,string memory _tokenURI) public onlyOwner {
        require (_destination != address(0), "Invalid address");
        balances[_destination]++;
        owners[_tokenId] = _destination;
        tokenURI[_tokenId] = _tokenURI;
        emit TokenMinted (_destination, _tokenId, _tokenURI);
     }

    function transfer(uint256 _tokenId,address _destination)public {
        require (owners[_tokenId] == msg.sender, "Not authorized");
        require (_destination != address(0), "Invalid address");
        balances[msg.sender]--;
        balances[_destination]++;
        owners[_tokenId] = _destination;
        emit TokenTransferred(msg.sender, _tokenId, _destination);
    }
 
    function getOwnerbyTokenId(uint256 _tokenId) public view returns (address){
        return(owners[_tokenId]);
    }
 
    function balanceOf(address _owner) public view returns (uint256){
        return (balances[_owner]);
    }
  
    function approve(address _to,uint256 _tokenId)public {
        require (msg.sender == owners[_tokenId], "Not authorized");
        require (_to != address(0), "Invalid address");
        tokenApproval[_tokenId] = _to;
    }
 
    function getApproval(uint256 _tokenId)public view returns(address){
        return (tokenApproval[_tokenId]);
    }
 
    function setOperator(address _operator)public {
        require (_operator != address(0),"Invalid address");
        tokenOperator[msg.sender][_operator] = true;
    }
 
    function getOperator(address _checkOperation)public view returns(bool){
        return (tokenOperator[msg.sender][_checkOperation]);
    }
 
    function removeOperator(address _account)public {
        require (_account != address(0),"Invalid address");
        tokenOperator[msg.sender][_account] = false;
    }
 
    function transferFrom(address _from,address _to,uint256 _tokenId)public{
        require (owners[_tokenId] == _from, "Transfer denied, You are not the owner of the token!"); 
        require (_from != address(0) && _to != address(0),"Invalid address");
        require(getApproval(_tokenId) == msg.sender || getOperator(msg.sender),"Access is denied!");
        balances[_from]--;
        balances[_to]++;
        owners[_tokenId]= _to;
        approve(_to,_tokenId);
        emit TokenTransferred(_from, _tokenId, _to);
    }
 
    function getTokenURI(uint256 _tokenId)public view returns(string memory){
        return(tokenURI[_tokenId]);
    }
}

// Token URI  is an address for information of a token
// logo address,  the address of whitepaper or ...
// It has json extension


