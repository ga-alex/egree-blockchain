pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;


contract EgreeClient {
	string[] HISTORY;
	string public VERSION = '0.1';
	address public GIVER;
	string PARENT;
	string HASH;

	constructor(address giver, string hash, string[] history, string parent) public {
		require(tvm.pubkey() != 0, 101);
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();

		GIVER = giver;
		HASH = hash;
		PARENT = parent;
		HISTORY = history;
	}

	function getVersion() public view returns(string){
		return VERSION;
	}

	function getHistory() public view returns(string[]){
		return HISTORY;
	}
}
