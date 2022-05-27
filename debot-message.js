const { TonClient, signerKeys, abiContract } = require("@tonclient/core");
const { libNode } = require("@tonclient/lib-node");
const { Account } = require("@tonclient/appkit");
const fs = require('fs');

TonClient.useBinaryLibrary(libNode);
const endpoints = ['http://ton-node'];
TonClient.defaultConfig = {
  network: {
    endpoints,
    message_retries_count: 6,
  },
  abi: {
    message_processing_timeout: 60,
  },
};


(async () => {
  const contract = {
    tvc: fs.readFileSync('debot/egree-debot.tvc', { encoding: 'base64', flag: 'r' }),
    abi: JSON.parse(fs.readFileSync('debot/egree-debot.abi.json'))
  }

  const signer = signerKeys(await TonClient.default.crypto.generate_random_sign_keys());
  
  const debot = new Account(
    contract,
    {
      address: '0:accf5b45510dd8c8439757dd377447dd66b5c8307f795819eaf5d1d771dc6cb4',
    }
  );

  const response = await debot.runLocal('getInvokeMessage', { egree_address: '0:fda96ca6d6bb0e2ca9f1e227dbcbdf9051911ac310873afab82f1c897643aa0b'});
  console.log(response)
})();
