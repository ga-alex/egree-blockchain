const { TonClient, signerKeys, abiContract } = require("@tonclient/core");
const { libNode } = require("@tonclient/lib-node");
const { Account } = require("@tonclient/appkit");
const fs = require('fs');

TonClient.useBinaryLibrary(libNode);
const setting = {
  generate: false
}

let keys = null;

(async () => {
  const endpoint = process.env.TON_NETWORK_ADDRESS || "http://ton-node";
  const client = new TonClient({ network: { endpoints: [endpoint] } });

  keys = await client.crypto.generate_random_sign_keys();


  try {
    const address = await main(client);
    await get2(client, address);
  } catch (err) {
    console.error(err);
  } finally {
    client.close();
  }
})();

async function main(client) {
  const tvc = fs.readFileSync('EgreeClient.tvc', { encoding: 'base64', flag: 'r' });
  const abi = JSON.parse(fs.readFileSync('EgreeClient.abi.json'));
  const AccContract = {
    abi,
    tvc
  };

  const signer = signerKeys(keys);
  const acc = new Account(AccContract, { signer, client });

  const address = await acc.getAddress();
  console.log(`New account future address: ${address}`);

  await acc.deploy({ 
    useGiver: true ,
    initInput: {
      giver: address,
      hash: Buffer.from('hashsum', 'utf8').toString('hex'),
      history: [
        Buffer.from('some string', 'utf8').toString('hex'),
        Buffer.from('other string', 'utf8').toString('hex'),
        Buffer.from('other string', 'utf8').toString('hex')
      ],
      parent: ''
    }
  });

  console.log("Account balance now is", await acc.getBalance());
  return address;
}


async function get2(client, address) {
  const tvc = fs.readFileSync('EgreeClient.tvc', { encoding: 'base64', flag: 'r' });
  const abi = JSON.parse(fs.readFileSync('EgreeClient.abi.json'));

  const contract = {
    abi,
    tvc
  };

  const dePoolAcc = new Account(contract, {
    address: address,
    client,
  });

  const version = await dePoolAcc.runLocal("getVersion", {});
  const history = await dePoolAcc.runLocal("getHistory", {});

  console.log(history.decoded.output.value0)
  console.log('Contract version:', Buffer.from(version.decoded.output.value0, 'hex').toString('utf8'))
  console.log('Contract:', Buffer.from(egree.decoded.output.value0, 'hex').toString('utf8'))
  console.log('UUID:', Buffer.from(uuid.decoded.output.value0, 'hex').toString('utf8'))
  history.decoded.output.value0.forEach(c => {
    console.log(Buffer.from(c, 'hex').toString('utf8'))
  })
  console.log(Buffer.from(history.decoded.output.value0, 'hex').toString('utf8'));
}