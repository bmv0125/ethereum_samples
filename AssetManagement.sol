pragma solidity >=0.4.22 <0.6.0;

contract AssetManagement {
    constructor() public {
        creator = msg.sender;
    }

    enum Status {Available, ForOrdering, OutOfStock, Removed}
    struct AssetItem {
        uint256 uniqId;
        string name;
        string description;
        string manufacurer;
        uint256 quantity;
        Status status;
        uint256 maxquantity;
    }
    address creator;
    mapping(uint256 => AssetItem) private assetStore;

    modifier onlyBy(address _account) {
        require(msg.sender == _account);
        _;
    }

    // events for different actions
    event CreateAsset(address account, string uniqId);
    event RejectAdding(address account, uint256 uniqId, string message);
    event RemoveAsset(address account, uint256 uniqId);
    event RejectOrder(address account, uint256 uniqId, string message);

    //function to add a product/asset to inventory
    function creatAsset(
        uint256 uniqId,
        string memory name,
        string memory description,
        string memory manufacurer,
        uint256 quantity,
        uint256 maxquantity
    ) public onlyBy(creator) {
        if (assetStore[uniqId].uniqId == uniqId) {
            emit RejectAdding(msg.sender, uniqId, "Asset already present");
            revert();
        } else {
            assetStore[uniqId] = AssetItem(
                uniqId,
                name,
                description,
                manufacurer,
                quantity,
                Status.Available,
                maxquantity
            );
        }
    }

    //function to remove a product/asset from inventory

    function removeAsset(uint256 uniqId) public onlyBy(creator) {
        AssetItem memory asset = assetStore[uniqId];

        asset.quantity = 0;
        asset.status = Status.Removed;
        emit RemoveAsset(msg.sender, uniqId);
    }

    //function to add a specific amount of quantity of a product/asset to inventory

    function addAssetQuantity(uint256 uniqId, uint256 quantity)
        public
        onlyBy(creator)
    {
        if (
            assetStore[uniqId].maxquantity >
            assetStore[uniqId].quantity + quantity
        ) {
            emit RejectAdding(
                msg.sender,
                uniqId,
                "Asset quantity exceeded maximum"
            );
        } else {
            AssetItem memory asset = assetStore[uniqId];
            asset.quantity += quantity;
        }
    }

    //function to order a specific amount of quantity of a product/asset from inventory

    function ordeAsset(uint256 uniqId, uint256 quantity) public {
        if (assetStore[uniqId].quantity > quantity) {
            emit RejectOrder(
                msg.sender,
                uniqId,
                "Asset quantity not available"
            );
        } else {
            AssetItem memory asset = assetStore[uniqId];
            asset.quantity -= quantity;
            if (asset.quantity == 0) {
                asset.status = Status.OutOfStock;
            }
        }
    }
}
