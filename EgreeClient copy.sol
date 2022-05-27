pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;


contract EgreeClient {
	struct Change {
		int time;
		string hash;
		string data;
		address sender;
	}

	struct Egree {
		string version;
		string uuid;
		string egree;
		Change history;
	}

	Change[] HISTORY;

  string public UUID;
	string public VERSION = '0.1';
	address public GIVER;
	string EGREE;

	constructor(address giver, string egree, string uuid, string hash, string data) public {
		require(tvm.pubkey() != 0, 101);
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();

		GIVER = giver;
		UUID = uuid;
		EGREE = egree;

		Change change = Change({
			time: now,
			data: data,
			hash: hash,
			sender: msg.sender
		});
		HISTORY.push(change);
	}

	// Check that message was signed with contracts key.
	modifier checkOwnerAndAccept {
		require(msg.pubkey() == tvm.pubkey(), 102);
		tvm.accept();
		_;
	}

	function storeChange(string hash, string data) public checkOwnerAndAccept {
		Change change = Change({
			time: now,
			data: data,
			hash: hash,
			sender: msg.sender
		});
		HISTORY.push(change);
	}

  function getEgree() public view returns(string){
		return EGREE;
	}

	function getVersion() public view returns(string){
		return VERSION;
	}

	function getUUID() public view returns(string){
		return UUID;
	}

	function getHistory() public view returns(Change[]){
		return HISTORY;
	}
}
