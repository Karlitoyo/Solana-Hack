// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import {Ownable} from "@openzeppelin/contracts/access/Whitelist.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// import "@openzeppelin/contracts/utils/Counters.sol";

contract InvoiceNFT is ERC721Enumerable, AccessControl {
    uint256 private _tokenIdCounter;
    event InvoiceMinted(address indexed to, uint256 tokenId);
    event InvoiceBurned(uint256 tokenId);
    struct InvoiceDetails {
        address assetAddress;
        uint256 amount;
        uint256 interest;
        uint256 startTime;
        uint256 duration;
        string assetName;
        string assetSymbol;
        string vaultName;
    }

    mapping(uint256 => InvoiceDetails) private _invoiceDetails;
    mapping(address => uint256[]) private _invoicesByLender;
    mapping(address => mapping(uint256 => uint256))
        private _invoiceIndexByLender;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC721("InvoiceNFT", "INV") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function addAdmin(address account) public virtual {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not a Admin"
        );
        grantRole(DEFAULT_ADMIN_ROLE, account);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function mintInvoice(
        address to,
        InvoiceDetails memory details
    ) external returns (uint256) {
        // Check that the calling account has the minter role
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not a Admin"
        );
        _tokenIdCounter++;
        uint256 newInvoiceId = _tokenIdCounter;
        _safeMint(to, newInvoiceId);
        _invoiceDetails[newInvoiceId] = details;
        _invoicesByLender[to].push(newInvoiceId);
        _invoiceIndexByLender[to][newInvoiceId] =
            _invoicesByLender[to].length -
            1;
        emit InvoiceMinted(to, newInvoiceId);
        return newInvoiceId;
    }

    function burnInvoice(uint256 tokenId) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Caller is not a Admin"
        );
        address tokenOwner = ownerOf(tokenId);

        uint256[] storage invoicesOfOwner = _invoicesByLender[tokenOwner];
        uint256 lastIndex = invoicesOfOwner.length - 1;
        uint256 invoiceIndex = _invoiceIndexByLender[tokenOwner][tokenId];

        uint256 lastInvoiceId = invoicesOfOwner[lastIndex];

        invoicesOfOwner[invoiceIndex] = lastInvoiceId;
        _invoiceIndexByLender[tokenOwner][lastInvoiceId] = invoiceIndex;

        invoicesOfOwner.pop();
        delete _invoiceIndexByLender[tokenOwner][tokenId];

        _burn(tokenId);
        delete _invoiceDetails[tokenId];

        emit InvoiceBurned(tokenId);
    }

    function getInvoiceDetails(
        uint256 tokenId
    ) external view returns (InvoiceDetails memory) {
        return _invoiceDetails[tokenId];
    }

    function getInvoicesOfLender(
        address lender
    ) external view returns (uint256[] memory) {
        return _invoicesByLender[lender];
    }
}