pragma solidity ^0.5.12;

import "./IERC721.sol";
import "./Ownable.sol";

contract KittyContract is Ownable, IERC721{
    uint256 public constant CREATION_LIMIT_GEN0 =10;
    string public constant name = "ZeeKitties";
    string public constant symbol = "ZK";

    event Birth(
        address owner, 
        uint256 kittenId, 
        uint256 mumId, 
        uint256 dadId, 
        uint256 genes
    );

    struct Kitty {
        uint256 genes;
        uint64 birthTime;
        uint32 mumId;
        uint32 dadId;
        uint16 generation;
    }

    Kitty[] kitties;

    mapping (uint256 => address) public kittyIndexToOwner;
    mapping (address => uint256) ownershipTokenCount;

    mapping (uint256 => address) public kittyIndexToApproved;
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    uint256 public gen0Counter;
    

    function balanceOf(address owner) external view returns (uint256 balance){
        return ownershipTokenCount[owner];
    }

    function totalSupply() public view returns (uint) {
        return kitties.length;
    }

    function ownerOf(uint256 _tokenId) external view returns (address)
    {
        return kittyIndexToOwner[_tokenId];
    }

    function transfer(address _to,uint256 _tokenId) external
    {
        require(_to != address(0));
        require(_to != address(this));
        require(_owns(msg.sender, _tokenId));

        _transfer(msg.sender, _to, _tokenId);
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownershipTokenCount[_to]++;

        kittyIndexToOwner[_tokenId] = _to;

        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            delete kittyIndexToApproved[_tokenId];
        }

        // Emit the transfer event.
        emit Transfer(_from, _to, _tokenId);
    }

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
      return kittyIndexToOwner[_tokenId] == _claimant;
    }

    function getKitty(uint256 _kittyId) public returns(
        uint256 genes,
        uint256 birthTime,
        uint256 mumId,
        uint256 dadId,
        uint256 generation
    ){
        Kitty storage kitty =  kitties[_kittyId];

        genes = kitty.genes;
        birthTime = kitty.birthTime;
        mumId = kitty.mumId;
        dadId = kitty.dadId;
        generation = kitty.generation;
    }

    function createKittyGen0(uint256 _genes) public onlyOwner returns(uint256){
        require(gen0Counter < CREATION_LIMIT_GEN0);
        gen0Counter++; 
        return _createKitty( 0, 0, 0, _genes, msg.sender);

    }

    function _createKitty(
        uint256 _mumId,
        uint256 _dadId,
        uint256 _generation,
        uint256 _genes,
        address _owner
    ) private returns(uint256) {
        Kitty memory kitty = Kitty({
            genes: _genes,
            birthTime: uint64(now),
            mumId:  uint32(_mumId),
            dadId:  uint32(_dadId),
            generation: uint16(_generation)
        });

        uint256 newKittyId = kitties.push(kitty) -1;
        emit Birth(_owner, newKittyId, _mumId, _dadId, _genes);
        _transfer(address(0), _owner, newKittyId);

        return newKittyId;
    }

    function approve(address _approved, uint256 _tokenId) external{
        //either the sender is the owner or is authorized for the owner 
        require(kittyIndexToOwner[_tokenId]==msg.sender  || 
            _operatorApprovals[kittyIndexToOwner[_tokenId]][msg.sender]);

        kittyIndexToApproved[_tokenId] = _approved;

        emit Approval(kittyIndexToOwner[_tokenId], _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved)  external{
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view returns (address){
        //check length for kitties array and throw if not valid id 
        require(isValidTokenId(_tokenId));

        return kittyIndexToApproved[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool){
        return _operatorApprovals[_owner][_operator];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external{
        require(_to != address(0), "to address cannot be zero address");
        require(_owns(_from, _tokenId), "from address is not the owner");

        require( msg.sender == _from || 
            kittyIndexToApproved[_tokenId] == msg.sender ||
            isApprovedForAll(_from, msg.sender),
            "message sender not authorized to transfer token");


        require(isValidTokenId(_tokenId), "not a valid kitty Id");

        _transfer(_from, _to, _tokenId);
    }

    
    function isValidTokenId(uint256 _tokenId) private view returns(bool){
        return _tokenId < kitties.length;
    }

}