pragma solidity 0.6.6;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControlMixin} from "../../common/AccessControlMixin.sol";
import {NativeMetaTransaction} from "../../common/NativeMetaTransaction.sol";
import {IBurnableERC721} from "./IBurnableERC721.sol";
import {ContextMixin} from "../../common/ContextMixin.sol";

contract DummyBurnableERC721 is
    ERC721,
    AccessControlMixin,
    NativeMetaTransaction,
    IBurnableERC721,
    ContextMixin
{
    bytes32 public constant PREDICATE_ROLE = keccak256("PREDICATE_ROLE");
    event Metadata(uint256 indexed tokenId, string data);

    constructor(string memory name_, string memory symbol_)
        public
        ERC721(name_, symbol_)
    {
        _setupContractId("DummyBurnableERC721");
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(PREDICATE_ROLE, _msgSender());
        _initializeEIP712(name_);
    }

    function _msgSender()
        internal
        override
        view
        returns (address payable sender)
    {
        return ContextMixin.msgSender();
    }

    /**
     * @dev See {IBurnableERC721-mint}.
     */
    function burn(uint256 tokenId) external override only(PREDICATE_ROLE) {
        _burn(tokenId);
    }

    function transferMetadata(uint256 tokenId, bytes calldata data) external override only(PREDICATE_ROLE) {
        // This function should decode metadata obtained from L2
        // and attempt to set it for this `tokenId`
        //
        // Following is just a default implementation, feel
        // free to define your own encoding/ decoding scheme
        // for L2 -> L1 token metadata transfer
        string memory uri = abi.decode(data, (string));

        _setTokenURI(tokenId, uri);
    }

    /**
     * If you're attempting to bring metadata associated with token
     * from L2 to L1, you must implement this method, to be invoked
     * when burning token on L1, during exit
     */
    function setTokenMetadata(uint256 tokenId, bytes memory data) internal virtual {
        // This function should decode metadata obtained from L2
        // & do further as per business requirement
        //
        // Following is just a default implementation, feel
        // free to define your own encoding/ decoding scheme
        // for L2 -> L1 token metadata transfer
        string memory uri = abi.decode(data, (string));
        emit Metadata(tokenId, uri);
    }

    /**
     * @dev See {IBurnableERC721-mint}.
     * 
     * If you're attempting to bring metadata associated with token
     * from L2 to L1, you must implement this method
     */
    function burn(uint256 tokenId, bytes calldata metaData) external override only(PREDICATE_ROLE) {
        _burn(tokenId);

        setTokenMetadata(tokenId, metaData);
    }


    /**
     * @dev See {IBurnableERC721-exists}.
     */
    function exists(uint256 tokenId) external view override returns (bool) {
        return _exists(tokenId);
    }
}