pragma solidity ^0.4.25;

interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
interface ERC721 {

  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  function balanceOf(address owner) public view returns (uint256 balance);
  function ownerOf(uint256 tokenId) public view returns (address owner);

  function approve(address to, uint256 tokenId) public;
  function getApproved(uint256 tokenId) public view returns (address operator);

  function setApprovalForAll(address operator, bool _approved) public;
  function isApprovedForAll(address owner, address operator)
    public view returns (bool);

  function transferFrom(address from, address to, uint256 tokenId) public;
  function safeTransferFrom(address from, address to, uint256 tokenId) public;

  function safeTransferFrom(address from, address to, uint256 tokenId, bytes data) public;
}


interface ERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the
    /// recipient after a `transfer`. This function MAY throw to revert and reject the transfer. Return
    /// of other than the magic value MUST result in the transaction being reverted.
    /// @notice The contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    /// unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
 }
contract CheckERC165 is ERC165 {
    mapping (bytes4 => bool) internal supportedInterfaces;

    constructor() public {
        supportedInterfaces[this.supportsInterface.selector] = true; 
        // ===0x01ffc9a7
    }
    function supportsInterface(bytes4 interfaceID) external view returns (bool){
        return supportedInterfaces[interfaceID];
    }
}
contract travblock is ERC721, CheckERC165 {
    using SafeMath for uint256;
    
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    // Mapping from token ID to owner
    address internal creator;
    mapping (uint256 => address) private _tokenOwner;
    
    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;
    
    // Mapping from owner to number of owned token
    mapping (address => uint256) private _ownedTokensCount;
    
    //Mapping from token ID to tokenData
    mapping(uint256 => string) private tokenData;
    
    //Mapping from owner to owner's tokenlist
    mapping(address => mapping(uint256 => uint256)) private tokenList;
    
    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;
    constructor() public {
        creator = msg.sender;
        
        //erc165 check
        supportedInterfaces[
            this.balanceOf.selector ^ 
            this.ownerOf.selector ^
            bytes4(keccak256("safeTransferFrom(address,address,uint256"))^
            bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes"))^
            this.transferFrom.selector ^
            this.approve.selector ^
            this.setApprovalForAll.selector ^
            this.getApproved.selector ^
            this.isApprovedForAll.selector
        ] = true;
    }

  function balanceOf(address owner) public view returns (uint256) {
    require(owner != address(0));
    return _ownedTokensCount[owner];
  }

  function ownerOf(uint256 tokenId) public view returns (address) {
    address owner = _tokenOwner[tokenId];
    require(owner != address(0));
    return owner;
  }
  
    function tokenMetadata(uint256 _tokenId) public view returns (string) {
        require(_tokenOwner[_tokenId]!=address(0));
        return tokenData[_tokenId];
    }

  /**
   * @dev Approves another address to transfer the given token ID
   * The zero address indicates there is no approved address.
   * There can only be one approved address per token at a given time.
   * Can only be called by the token owner or an approved operator.
   * @param to address to be approved for the given token ID
   * @param tokenId uint256 ID of the token to be approved
   */
  function approve(address to, uint256 tokenId) public {
    address owner = ownerOf(tokenId);
    require(to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    _tokenApprovals[tokenId] = to;
    emit Approval(owner, to, tokenId);
  }

  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * Reverts if the token ID does not exist.
   * @param tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for the given token ID
   */
  function getApproved(uint256 tokenId) public view returns (address) {
    require(_exists(tokenId));
    return _tokenApprovals[tokenId];
  }

  /**
   * @dev Sets or unsets the approval of a given operator
   * An operator is allowed to transfer all tokens of the sender on their behalf
   * @param to operator address to set the approval
   * @param approved representing the status of the approval to be set
   */
  function setApprovalForAll(address to, bool approved) public {
    require(to != msg.sender);
    _operatorApprovals[msg.sender][to] = approved;
    emit ApprovalForAll(msg.sender, to, approved);
  }

  /**
   * @dev Tells whether an operator is approved by a given owner
   * @param owner owner address which you want to query the approval of
   * @param operator operator address which you want to query the approval of
   * @return bool whether the given operator is approved by the given owner
   */
  function isApprovedForAll(address owner, address operator) public view returns (bool)
  {
    return _operatorApprovals[owner][operator];
  }
  function transferFrom(address from, address to, uint256 tokenId) public{
    require(_isApprovedOrOwner(msg.sender, tokenId));
    require(to != address(0));
    /*
    _clearApproval(from, tokenId);
    _removeTokenFrom(from, tokenId);
    _addTokenTo(to, tokenId);

    emit Transfer(from, to, tokenId);*/
  }

  function safeTransferFrom(address from, address to, uint256 tokenId) public{
    // solium-disable-next-line arg-overflow
    //safeTransferFrom(from, to, tokenId, "");
  }

  function safeTransferFrom(address from, address to, uint256 tokenId, bytes _data) public{
    /*transferFrom(from, to, tokenId);
    // solium-disable-next-line arg-overflow
    require(_checkOnERC721Received(from, to, tokenId, _data));*/
  }
  function _exists(uint256 tokenId) internal view returns (bool) {
    address owner = _tokenOwner[tokenId];
    return owner != address(0);
  }
  function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool){
    address owner = ownerOf(tokenId);
    return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
  }
  
  function _mint(address to, uint256 tokenId, string data) public {
    require(to != address(0));
    _addTokenTo(to, tokenId);
    tokenData[tokenId] = data;
    emit Transfer(address(0), to, tokenId);
  }

  /**
   * @dev Internal function to burn a specific token
   * Reverts if the token does not exist
   * @param tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address owner, uint256 tokenId) public {
    _clearApproval(owner, tokenId);
    _removeTokenFrom(owner, tokenId);
    emit Transfer(owner, address(0), tokenId);
  }

  /**
   * @dev Internal function to add a token ID to the list of a given address
   * Note that this function is left internal to make ERC721Enumerable possible, but is not
   * intended to be called by custom derived contracts: in particular, it emits no Transfer event.
   * @param to address representing the new owner of the given token ID
   * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function _addTokenTo(address to, uint256 tokenId) public {
    require(_tokenOwner[tokenId] == address(0));
    require(to != address(0));
    _ownedTokensCount[to] = _ownedTokensCount[to].add(1);
    _tokenOwner[tokenId] = to;
    tokenList[to][_ownedTokensCount[to]] = tokenId;
  }

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * Note that this function is left internal to make ERC721Enumerable possible, but is not
   * intended to be called by custom derived contracts: in particular, it emits no Transfer event,
   * and doesn't clear approvals.
   * @param from address representing the previous owner of the given token ID
   * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function _removeTokenFrom(address from, uint256 tokenId) public {
    require(ownerOf(tokenId) == from);
    uint256 i;
    for(i=1; i<=_ownedTokensCount[from] ; i = i.add(1)){
        if(tokenList[from][i] == tokenId) break;
    }
    for(; i<=_ownedTokensCount[from] ; i = i.add(1)){
        tokenList[from][i] = tokenList[from][i+1];
    }
    _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
    _tokenOwner[tokenId] = address(0);
  }

  /**
   * @dev Private function to clear current approval of a given token ID
   * Reverts if the given address is not indeed the owner of the token
   * @param owner owner of the token
   * @param tokenId uint256 ID of the token to be transferred
   */
  function _clearApproval(address owner, uint256 tokenId) private {
    require(ownerOf(tokenId) == owner);
    if (_tokenApprovals[tokenId] != address(0)) {
      _tokenApprovals[tokenId] = address(0);
    }
  }
 }
 library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, 
    // but the benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}