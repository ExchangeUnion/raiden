import "NettingChannelContract.sol";
library IterableMappingNCC {
    struct itmap {
        mapping(bytes32 => IndexValue) data;
        KeyFlag[] keys;
        uint size;
    }
    struct IndexValue { uint keyIndex; NettingChannelContract value; }
    struct KeyFlag { bytes32 key; bool deleted; }


    function insert(
        itmap storage self,
        bytes32 key,
        address assetAdr,
        address sender,
        address partner,
        uint lckdTime
    )
        returns(bool replaced, NettingChannelContract nc
    ) {
        uint keyIndex = self.data[key].keyIndex;
        nc = new NettingChannelContract(assetAdr, sender, partner, lckdTime);
        self.data[key].value = nc;
        if (keyIndex > 0)
            replaced =  true;
        else {
            keyIndex = self.keys.length++;
            self.data[key].keyIndex = keyIndex + 1;
            self.keys[keyIndex].key = key;
            self.size++;
            replaced = false;
        }
    }


    function remove(itmap storage self, bytes32 key) returns (bool success){
        uint keyIndex = self.data[key].keyIndex;
        if (keyIndex == 0)
          return false;
        delete self.data[key];
        self.keys[keyIndex - 1].deleted = true;
        self.size --;
    }


    function contains(itmap storage self, bytes32 key) returns (bool) {
        return self.data[key].keyIndex > 0;
    }


    function atIndex(itmap storage self, bytes32 key) returns (uint index) {
        return self.data[key].keyIndex;
    }


    function iterate_start(itmap storage self) returns (uint keyIndex){
        return iterate_next(self, uint(-1));
    }


    function iterate_valid(itmap storage self, uint keyIndex) returns (bool){
        return keyIndex < self.keys.length;
    }


    function iterate_next(itmap storage self, uint keyIndex) returns (uint r_keyIndex){
        keyIndex++;
        while (keyIndex < self.keys.length && self.keys[keyIndex].deleted)
            keyIndex++;
        return keyIndex;
    }


    function iterate_get(itmap storage self, uint keyIndex) returns (bytes32 key, NettingChannelContract value){
        key = self.keys[keyIndex].key;
        value = self.data[key].value;
    }
}
