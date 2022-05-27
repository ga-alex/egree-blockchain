pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "Debot.sol";
import "Terminal.sol";
import "Menu.sol";
import "AddressInput.sol";
import "ConfirmInput.sol";
import "Upgradable.sol";
import "Sdk.sol";


interface IEgree {
   function getHistory() external returns (string[] history);
   function storeChange(string hash, string uuid, string reason) external;
}

contract EgreeDebot is Debot, Upgradable {
    bytes m_icon;
    TvmCell m_code;
    address m_address;

    function setCode(TvmCell code) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        m_code = code;
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }


    function start() public override {
        AddressInput.get(tvm.functionId(saveAddress),"Please enter egree contract address");
    }

    function getAddress() public {
        AddressInput.get(tvm.functionId(saveAddress),"Please enter egree contract address");
    }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "egree DeBot";
        version = "0.1.0";
        publisher = "egree";
        key = "egree history check";
        author = "egree inc.";
        support = address.makeAddrStd(0, 0x66e01d6df5a8d7677d9ab2daf7f258f1e2a7fe73da5320300395f99e01dc3b5f);
        hello = "Hi, i'm a egree DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }

    function saveAddress(address value) public {
        m_address = value;
        Sdk.getAccountType(tvm.functionId(checkStatus), m_address);
    }

    function checkStatus(int8 acc_type) public {
        if (acc_type == 1) {
            _menu();
        } else if (acc_type == -1)  { // acc is inactive
            Terminal.print(0, "There is no egree contract");
        } else  if (acc_type == 0) { // acc is uninitialized
        } else if (acc_type == 2) {  // acc is frozen
            Terminal.print(0, format("Can not continue: account {} is frozen", m_address));
        }
    }

    function getHistory() public {
        Terminal.print(0, format("Egree history: {}", m_address));
        IEgree(m_address).getHistory{
            abiVer: 2,
            extMsg: true,
            sign: false,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showHistory_),
            onErrorId: tvm.functionId(onError)
        }();
    }


    function _menu() private {
        string sep = '----------------------------------------';
        Menu.select(
            format("Menu"),
            sep,
            [
                MenuItem("Show egree history hash","",tvm.functionId(getHistory)),
                MenuItem("Check other adress","",tvm.functionId(getAddress))
            ]
        );
    }

    function showHistory_( string[] history ) public {
        uint32 i;
        Terminal.print(0, "Egree history:");
        // Terminal.print(0, format("{}  ", history.length));
        if (history.length > 0 ) {
            // Terminal.print(0, "Egree history:");
            for (i = 0; i < history.length; i++) {
                string line = history[i];
                Terminal.print(0, format("{}", line));
            }
        } else {
            Terminal.print(0, "Egree history is empty");
        }
        _menu();
    }


    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

    function invoke(address egree_address) public {
        IEgree(egree_address).getHistory{
            abiVer: 2,
            extMsg: true,
            sign: false,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showHistory_),
            onErrorId: tvm.functionId(onError)
        }();
    }

    function getInvokeMessage(address egree_address) public pure returns(TvmCell message) {
        TvmCell body = tvm.encodeBody(EgreeDebot.invoke, egree_address);
        TvmBuilder message_;
        // message_.store(false, true, true, false, address(0), address(this));
        // message_.storeTons(0);
        // message_.storeUnsigned(0, 1);
        // message_.storeTons(0);
        // message_.storeTons(0);
        // message_.store(uint64(0));
        // message_.store(uint32(0));
        // message_.storeUnsigned(0, 1); //init: nothing$0
        // message_.storeUnsigned(1, 1); //body: right$1
        message_.store(body);
        message = message_.toCell();
    }
}