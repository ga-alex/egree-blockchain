require('dotenv').config()
const { TonClient, signerKeys, abiContract } = require("@tonclient/core");
const { libNode } = require("@tonclient/lib-node");
const { Account } = require("@tonclient/appkit");
const fs = require('fs');

TonClient.useBinaryLibrary(libNode);
// This file for test purpose only!

const settings = {
  generate: false,
  address: '0:3dcd56cd520c4f1e08ecd36b4bc59b63c1926728c97e8242a7889cb97ea0d6d2'
}

let keys = null;

(async () => {
  const endpoint = process.env.TON_NETWORK_ADDRESS || 'http://ton-node';
  const client = new TonClient({ network: { endpoints: [endpoint] } });

  if (settings.generate){
    keys = await client.crypto.generate_random_sign_keys();
  } else {
    keys = {
      public: process.env.public,
      secret: process.env.secret
    };
  }
  
  try {
    await get(client, settings.address)
  } catch (err) {
    console.error(err);
  } finally {
    client.close();
  }
})();


async function runFunction(client, address, function_name, input = {} ) {
  const abiJson = JSON.parse(fs.readFileSync('EgreeClient.abi.json'));
  const abi = abiContract(abiJson);
  const signer = signerKeys(keys);

  const params = {
    send_events: false,
    message_encode_params: {
      address,
      abi,
      call_set: {
        function_name,
        input
      },
      signer: { type: 'None' }
    }
  }

  const response = await client.processing.process_message(params);
  return response
}

async function update(client, address) {
  const response = await runFunction(client, address, 'storeChange', {
    hash: Buffer.from('UpdateHASH', 'utf8').toString('hex'),
    uuid: Buffer.from('UpdateUUID', 'utf8').toString('hex'),
    reason: Buffer.from('UpdateReason', 'utf8').toString('hex'),
  });

  return response;
}

async function get(client, address) {
  const tvc = fs.readFileSync('EgreeClient.tvc', { encoding: 'base64', flag: 'r' });
  const abi = JSON.parse(fs.readFileSync('EgreeClient.abi.json'));

  const contract = {
    abi,
    tvc
  };

  const dePoolAcc = new Account(contract, {
    address: address,
    client,
    signer: signerKeys(keys),
  });

  const response = await dePoolAcc.runLocal("getHistory", {});

  console.log('Contract address:', address)
  console.log(`Info:`, response.decoded.output);

  console.log(Buffer.from(response.decoded.output.value0[0].hash, 'hex').toString('utf8'));
  console.log(Buffer.from('hashsum', 'utf8').toString('hex'))
  console.log(response.decoded.output.value0[0].hash)
  return response;
}