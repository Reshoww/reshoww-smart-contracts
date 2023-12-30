// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

import "./Book.sol";

struct BookObj {
    string title;
    address addr;
    address owner;
    address host;
    uint256 collateralPrice;
}

struct BookInRental {
    address tenant;
    address host;
    address owner;
    uint256 hostFee;
    uint256 ownerFee;
    uint256 depositFee;
}

struct Host {
    uint256 ownerRentalPercentageFee;
    uint256 hostRentalPercentageFee;
}

contract BookRental {
    event BookCreated (
        address indexed _owner,
        address indexed _host,
        address _bookNFT,
        string _bookTitle,
        uint256 _bookPrice
    );

    event BookRented(
        address indexed _tenant,
        address indexed _book
    );

    event BookRentalEndedAndAccepted(
        uint256 _timestamp,
        address indexed _book
    );

    event BookRentalEndedAndNotAccepted(
        uint256 _timestamp,
        address indexed _book
    );

    event BookRentEndRequested(
        uint256 _timestamp,
        address indexed _book
    );

    event HostShouldBeCreatedFirst(
        address indexed _sender
    );

    event HostCreated(
        uint256 _ownerRentFeePercentage,
        uint256 _hostRentFeePercentage
    );

    event BookRentalRequested(
       address _tenant,
       address _sender
    );

    // book address to book in rental item.
    mapping(address => BookInRental) public booksInRental;
    // book address to book availability.
    mapping(address => bool) private booksInRentalEndConfirmationQueue;
    // user address to host.
    mapping(address => Host) public hosts;
    // book address to book.
    mapping(address => BookObj) public books;

    uint256 private constant tokenId = 1;

    modifier _onlyTenant(address _book, address _sender) {
        require(booksInRental[_book].tenant == _sender, "Only tenant (reader) can perform action with this book");
        _;
    }

    modifier _onlyHost(address _book, address _sender) {
        require(booksInRental[_book].host == _sender, "Only host (library) can perform action with this book");
        _;
    }

    modifier _allowedToRent(address _book)
    {
        require(books[_book].collateralPrice > 0, "Book in not existed");
        require(booksInRental[_book].hostFee == 0, "Book already in rental");
        _;
    }

    modifier _returnOnlyRequested(address _book) {
        require(booksInRentalEndConfirmationQueue[_book] == true, "Reader did not sent request to end rental");
        _;
    }

    modifier _returnOnlyInRental(address _book) {
        require(booksInRental[_book].hostFee > 0, "Reader did not sent request to end rental");
        _;
    }

    modifier _priceThresholdCorrect(uint256 _ownerFee, uint256 _sharerFee) {
        require(_ownerFee <= 5, "Host daily fee should be lower then 5%");
        require(_sharerFee <= 5, "Owner daily fee should be lower then 5%");
        _;
    }

    function rentBook(address _book, uint256 _hostFee, uint256 _ownerFee, uint256 _depositFee) public payable _allowedToRent(_book) {
        BookObj memory bookToRent = books[_book];
        Host memory hostOfTheBook = hosts[bookToRent.host];

        booksInRental[bookToRent.addr] = BookInRental(
            msg.sender,
            bookToRent.host,
            bookToRent.owner,
            _hostFee,
            _ownerFee,
            _depositFee
        );

        Book b = Book(_book);
        b.transferTo(msg.sender);

        emit BookRented(b.ownerOf(tokenId), bookToRent.addr);
    }

    function endRent(address _book) public _onlyTenant(_book, msg.sender) {
        booksInRentalEndConfirmationQueue[_book] = true;

        emit BookRentEndRequested(block.timestamp, _book);
    }

    function dissalowEndRent(address _book) public _returnOnlyRequested(_book) _onlyHost(_book, msg.sender) {
        BookInRental memory rentedBook = booksInRental[_book];
        
        this.transferEther(payable(rentedBook.owner), rentedBook.depositFee + rentedBook.ownerFee);
        this.transferEther(payable(rentedBook.host), rentedBook.hostFee);

        delete booksInRental[_book];
        delete booksInRentalEndConfirmationQueue[_book];

        Book b = Book(_book);
        b.destroy();

        emit BookRentalEndedAndNotAccepted(block.timestamp, _book);
    }

    function confirmEndRent(address _book) public _returnOnlyRequested(_book) _onlyHost(_book, msg.sender){
        BookInRental memory rentedBook = booksInRental[_book];

        this.transferEther(payable(rentedBook.tenant), rentedBook.depositFee);
        this.transferEther(payable(rentedBook.host), rentedBook.hostFee);
        this.transferEther(payable(rentedBook.owner), rentedBook.ownerFee);

        delete booksInRental[_book];
        delete booksInRentalEndConfirmationQueue[_book];

        Book b = Book(_book);
        b.transferTo(address(this));

        emit BookRentalEndedAndAccepted(block.timestamp, _book);
    }

    function becomeHost(uint256 _ownerFeePercentage, uint256 _hostFeePercentage) public _priceThresholdCorrect(_hostFeePercentage, _ownerFeePercentage){
        hosts[msg.sender] = Host(_ownerFeePercentage, _hostFeePercentage);

        emit HostCreated(_ownerFeePercentage, _hostFeePercentage);
    }

    function createBook(string memory _name, string memory _isbn, address _owner, uint256 _priceInFiat) public {
        if (hosts[msg.sender].ownerRentalPercentageFee > 0) {
            Book book = new Book(_name, _isbn);

            books[book.getAddr()] = BookObj(_name, book.getAddr(), _owner, msg.sender, _priceInFiat);

            emit BookCreated(_owner, msg.sender, book.getAddr(), _name, _priceInFiat);
        } else {
            emit HostShouldBeCreatedFirst(msg.sender);
        }
    }

    function transferEther(address payable _recipient, uint256 _amount) external payable {
        (bool success, bytes memory data) = _recipient.call{value:_amount}("");

        require(success, "Transfer ETH (contract internal) transaction failed");
    }

    function bookInRental(address _book) public view returns (bool) {
        return booksInRental[_book].hostFee > 0;
    }

    function isUserHost(address _userAddr) public view returns (bool) {
        return hosts[_userAddr].ownerRentalPercentageFee > 0;
    }
}
