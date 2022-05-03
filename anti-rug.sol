// SPDX-License-Identifier: GPL-3.0


pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  uint public mintingStartTimestamp;
  uint constant quarterlyLockPeriod = 12 weeks;
  uint256 public votecount;
  address _owner = 0xc03129e9D3d03B18b4CaE44bc4Bd04fEc15f8a71;

  //Maps token IDs with voting status. 
  mapping (uint256 => bool) public voted;
  //maps token IDs with refunded status.
  mapping (uint256 => bool) public refunded;
  
 
  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    mintingStartTimestamp = 1635109200;
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // public
  function mint(uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
      splitBalance(msg.value/_mintAmount);
    }
  }



   function splitBalance(uint256 amount) private {
        uint256 lockedShare = amount/75;
        uint256 ownerInitialShare = (amount - lockedShare);
        payable(_owner).transfer(ownerInitialShare);
    }


  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }


   function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }


    //voting

    //checks if the caller is a holder
    modifier onlyTokenholders {
        if (balanceOf(msg.sender) == 0) revert();
            _;
    }


    //checks if vote count has reached a threshold.
    modifier eligibleRefund {
        require(votecount >= totalSupply() * 90 / 100);
        _;
    }

   
    

    function vote() onlyTokenholders public returns (uint256 _votecount) {
        uint count = balanceOf(msg.sender);
        uint256 number;
        for(uint i=0; i < count; i++){
            uint tokenId = tokenOfOwnerByIndex(msg.sender, i);
            require (voted[tokenId] = false);
            voted[tokenId] = true;
            number++;

          }
        votecount += votecount;
        return votecount;

    }


    

    function getRefundCount(address caller) internal returns (uint256 _value) {
        uint count = balanceOf(caller);
 
        for(uint i=0; i < count; i++) {
            uint tokenId = tokenOfOwnerByIndex(msg.sender, i);
            uint256 number;
            require (refunded[tokenId] = false);
            number++;
             _value = number;
        }
       
        return _value;

        }
 
    

    function refund() public onlyTokenholders eligibleRefund
     {
        uint256 count = getRefundCount(msg.sender);
        uint balance = address(this).balance;
        uint share = (balance / totalSupply()) * count;
        

        for(uint i=0; i < count; i++){
            uint tokenId = tokenOfOwnerByIndex(msg.sender, i);
            refunded[tokenId] = true;
             }
         payable(msg.sender).transfer(share);
    }

  function withdraw() external payable onlyOwner {
   
    //owner withdrawal share first quarter.
    if (block.timestamp >= mintingStartTimestamp + quarterlyLockPeriod){
            payable(_owner).call{value: address(this).balance * 25 / 100};
    
    }
    
    //owner withdrawal share second quarter.
    else if (block.timestamp >= mintingStartTimestamp + quarterlyLockPeriod * 2){
            payable(_owner).call{value: address(this).balance * 33 / 100};
            
    }

    //owner withdrawal share third quarter.
    else if (block.timestamp >= mintingStartTimestamp + quarterlyLockPeriod * 3){
            payable(_owner).call{value: address(this).balance * 50 / 100};
          
        }
    //owner withdrawal share forth quarter.
    require (block.timestamp >= mintingStartTimestamp *4);
    payable(_owner).call{value: address(this).balance};
    
    }
   

   
  
}