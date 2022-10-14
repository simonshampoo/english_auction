// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address,
        address,
        uint256
    ) external;
}

contract EnglishAuction {
    event Started();
    event BidSent(address indexed bidder, uint256 amount);
    event WithdrawnBid(address indexed bidder, uint256 amount);
    event Ended(address winner, uint256 amount);

    struct Bid {
        address sender;
        uint256 time;
        uint256 amountBid;
    }
    uint256 immutable endingTime;
    uint256 immutable reservePrice;
    Bid highestCurrentBidder;
    ERC721 item;
    mapping(address => Bid[]) bids;
    modifier afterAuction() {
        require(block.timestamp >= endingTime);
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _reservePrice
    ) {
        endingTime = block.timestamp;
        reservePrice = _reservePrice;
        item = ERC721(_name, _symbol, 18);
    }

    function makeBid(uint256 amount) public payable {
        if (bids[msg.sender].length != 0) {} //user has a previous bid, lets refund it before they commit another bid
        Bid memory bid = Bid(msg.sender, block.timestamp, msg.value);
        bids[msg.sender].push(bid);
        if (msg.value > highestCurrentBidder.amountBid) {
            highestCurrentBidder = bid; //sus, check this out later
        }
    }

    function retrieveBidsFrom(address bidder)
        public
        view
        returns (Bid[] memory)
    {
        return bids[bidder];
    }

    function receive() {}
}
