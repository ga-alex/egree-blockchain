pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;


interface Storage {
	function storeValue(uint value) external;
}


contract UintStorage is Storage {
	uint public value;
	address public clientAddress;

	// This function can be called only by another contract. There is no 'tvm.accept()'
	function storeValue(uint v) public override {
		value = v;
		clientAddress = msg.sender;
	}
}