pragma solidity ^0.5.0;

import "./Ownable.sol";
import "./IKittyMarketplace.sol";

contract KittyMarketPlace is Ownable, IKittyMarketPlace {
    KittyContract private _kittyContract;

    struct Offer {
        address payable seller;
        uint256 price;
        uint256 index;
        uint256 tokenId;
        bool active;
    }

    Offer[] offers;

    mapping(uint256 => Offer) tokenIdToOffer;

    function setKittyContract(address _kittyContractAddress) public onlyOwner{
        _kittyContract = KittyContract(_kittyContractAddress);
    }

    constructor(address _kittyContractAddress) public {
      setKittyContract(_kittyContractAddress);
    }

    function getOffer(uint256 _tokenId) external view returns ( 
        address seller, uint256 price, uint256 index, uint256 tokenId, bool active){
            require(tokenIdToOffer[_tokenId].active, "no active offer for token");

            Offer storage offer = tokenIdToOffer[_tokenId];
            seller = offer.seller;
            price = offer.price;
            index = offer.index;
            tokenId = offer.tokenId;
            active = offer.active;
    }
    function getAllTokenOnSale() external  returns(uint256[] memory listOfOffers){
        uint256 totalOffers = offers.length;
      
      if (totalOffers == 0) {
          return new uint256[](0);
      } 
      else {
        uint256[] memory result = new uint256[](totalOffers);

        for (uint256 offerId = 0; offerId < totalOffers; offerId++) {
          if(offers[offerId].active == true){
            result[offerId] = offers[offerId].tokenId;
          }
        }
        return result;
      }

    }
    function _ownsKitty(address _address, uint256 _tokenId)
        internal
        view
        returns (bool)
    {
        return (_kittyContract.ownerOf(_tokenId) == _address);
    }


    function setOffer(uint256 _price, uint256 _tokenId) external{
        require (_ownsKitty(msg.sender, _tokenId), "only the owner can create an offer");
        require(!tokenIdToOffer[_tokenId].active, "There's already an active offer for this token");
        require(_kittyContract.getApproved(_tokenId) ==address(this));

        Offer memory offer = Offer({
            seller: msg.sender,
            price: _price,
            index: offers.length,
            tokenId: _tokenId,
            active: true
            
        });
        offers.push(offer);

        tokenIdToOffer[_tokenId] = offer;
        emit MarketTransaction("Create offer", msg.sender, _tokenId);
    }

    function removeOffer(uint256 _tokenId) external{
        Offer memory offer = tokenIdToOffer[_tokenId];
        require(
            offer.seller == msg.sender,
            "You are not the seller of that kitty"
        );

        delete tokenIdToOffer[_tokenId];
        offers[offer.index].active = false;

        emit MarketTransaction("Remove offer", msg.sender, _tokenId);
    }

    function buyKitty(uint256 _tokenId) external payable{
        Offer memory offer = tokenIdToOffer[_tokenId];
        require(msg.value == offer.price);
        require(offer.active);

        // Important: delete the kitty from the mapping BEFORE paying out to prevent reentry attacks
        delete tokenIdToOffer[_tokenId];
        offers[offer.index].active = false;

        // Transfer the funds to the seller
        if (offer.price > 0) {
            offer.seller.transfer(offer.price);
        }

        // Transfer ownership of the kitty
        _kittyContract.transferFrom(offer.seller, msg.sender, _tokenId);

        emit MarketTransaction("Buy", msg.sender, _tokenId);

    }
}