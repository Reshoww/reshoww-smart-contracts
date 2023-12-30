// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Book is ERC721 {
    address private assetOwner;
    address private owner;
    uint256 private constant tokenId = 1;
    uint256 private transfersCount = 0;

    event MallitiousCall(
        address _caller,
        address indexed _contractOwner
    );
    event BookTransfered(
        address _to
    );
    event BookDestroyed(
        uint256 _timestamp
    );

    modifier _onlyOwner() {
        bool isCallerOwner = msg.sender == owner;
        
        if (!isCallerOwner) {
            emit MallitiousCall(msg.sender, owner);
        }

        require(isCallerOwner, "Only owner can execute this");

        _;
    }

    constructor(string memory _bookName, string memory _bookISBN) ERC721(_bookName, _bookISBN) {
        assetOwner = msg.sender;
        owner = msg.sender;
        
        _mint(msg.sender, tokenId);
    }

    function getAddr() public view returns (address) {
        return address(this);
    }

    function transferTo(address _to) public _onlyOwner() {
        _transfer(assetOwner, _to, tokenId);

        transfersCount = transfersCount + 1;
        assetOwner = _to;

        emit BookTransfered(_to);
    }

    function destroy() public _onlyOwner() {
        _burn(tokenId);

        emit BookDestroyed(block.timestamp);
    }
}
