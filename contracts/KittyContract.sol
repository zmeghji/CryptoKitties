pragma solidity ^0.5.12;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./Ownable.sol";

contract KittyContract is Ownable, IERC721{
    uint256 public constant CREATION_LIMIT_GEN0 =10;
    string public constant name = "ZeeKitties";
    string public constant symbol = "ZK";

    bytes4 internal constant MAGIC_ERC721_RECEIVED = bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;   

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
    

    function supportsInterface(bytes4 _interfaceId) external view returns (bool){
        return ( _interfaceId == _INTERFACE_ID_ERC721 || _interfaceId == _INTERFACE_ID_ERC165);
    }

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
        
        require(_isApprovedOrOwner(msg.sender, _from, _to, _tokenId));
        _transfer(_from, _to, _tokenId);
    }

    
    function isValidTokenId(uint256 _tokenId) private view returns(bool){
        return _tokenId < kitties.length;
    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public {
        require( _isApprovedOrOwner(msg.sender, _from, _to, _tokenId) );
        _safeTransfer(_from, _to, _tokenId, _data);
    }

    function _safeTransfer(address _from, address _to, uint256 _tokenId, bytes memory _data) internal{
        _transfer(_from, _to, _tokenId);
        require( _checkERC721Support(_from, _to, _tokenId, _data) );
    }
    function _checkERC721Support(address _from, address _to, uint256 _tokenId, bytes memory _data) 
        internal returns (bool){
        if( !_isContract(_to) ){
            return true;
        }
        //Call onERC721Received in the _to contract
        bytes4 returnData = IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
        //Check return value
        return returnData == MAGIC_ERC721_RECEIVED;
    }

    function _isContract(address _to) internal view returns (bool){
        uint32 size;
        assembly{
            size := extcodesize(_to)
        }
        return size > 0;
    }

    function _isApprovedOrOwner(address _spender, address _from, address _to, uint256 _tokenId) internal view returns (bool) {
        require(_tokenId < kitties.length); //Token must exist
        require(_to != address(0)); //TO address is not zero address
        require(_owns(_from, _tokenId)); //From owns the token
        
        //spender is from OR spender is approved for tokenId OR spender is operator for from
        return (_spender == _from || _approvedFor(_spender, _tokenId) || isApprovedForAll(_from, _spender));
    }

    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return kittyIndexToApproved[_tokenId] == _claimant;
    }

    function getKittyByOwner(address _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](ownershipTokenCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < kitties.length; i++) {
            if (kittyIndexToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function breed(uint256 _dadId, uint256 _mumId) public returns (uint256){

        require(_owns(msg.sender, _dadId), "The user doesn't own the token");
        require(_owns(msg.sender, _mumId), "The user doesn't own the token");

        ( uint256 dadDna,,,,uint256 DadGeneration ) = getKitty(_dadId);

        ( uint256 mumDna,,,,uint256 MumGeneration ) = getKitty(_mumId);
        
        uint256 newDna = _mixDna(dadDna, mumDna);

        uint256 kidGen = 0;
        if (DadGeneration < MumGeneration){
            kidGen = MumGeneration + 1;
        } else if (DadGeneration > MumGeneration){
            kidGen = DadGeneration + 1;
        } else{
            kidGen = MumGeneration + 1;
        }

        return _createKitty(_mumId, _dadId, kidGen, newDna, msg.sender);
    }
    function _mixDna(uint256 _dadDna, uint256 _mumDna) internal returns (uint256){
        //dadDna: 11 22 33 44 55 66 77 88 
        //mumDna: 88 77 66 55 44 33 22 11

        uint256 firstHalf = _dadDna / 100000000; //11223344
        uint256 secondHalf = _mumDna % 100000000; //44332211
        
        uint256 newDna = firstHalf * 100000000;
        newDna = newDna + secondHalf; 
        return newDna;
    }

}