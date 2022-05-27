#!/bin/bash
set -e
debot=0:accf5b45510dd8c8439757dd377447dd66b5c8307f795819eaf5d1d771dc6cb4
debot_name=egree-debot

if [ $# -eq 0 ]; then
    echo "Builds internal message for Multisig DeBot with encoded transaction parameters."
    echo "Message can be sent later to DeBot to submit new multisig transaction."
    echo "USAGE:"
    echo "  ${0} RECIPIENT AMOUNT BOUNCE PAYLOAD"
    echo "    where:"
    echo "      RECIPIENT - required, TON address of funds recipient"
    echo "      AMOUNT - required, amount of nanotokens to transfer"
    echo "      BOUNCE - required, sets bounce flag: true or false"
    echo "      PAYLOAD - optional, internal message body for recipient smart contract (BOC encoded as base64)"
    echo ""
    echo "EXAMPLE:"
    echo "  ${0} 0:09403116d2d04f3d86ab2de138b390f6ec1b0bc02363dbf006953946e807051e 1000000000 true"
    exit 1
fi

tos=./tonos-cli
if $tos --version > /dev/null 2>&1; then
    echo "OK $tos installed locally."
else
    tos=tonos-cli
    if $tos --version > /dev/null 2>&1; then
        echo "OK $tos installed globally."
    else
        echo "$tos not found globally or in the current directory. Please install it and rerun script."
        exit
    fi
fi

if test -f "$debot_name.abi.json"; then
    echo "OK $debot_name.abi.json found."
else
    echo "$debot_name.abi.json not found in the current directory."
    exit
fi

PAYLOAD="${4:-\"\"}"

tonos-cli -u http://ton-node run $debot getInvokeMessage "{\"egree_address\":\"0:accf5b45510dd8c8439757dd377447dd66b5c8307f795819eaf5d1d771dc6cb4\"}"  --abi $debot_name.abi.json \
    | grep message | cut -d '"' -f 4 | tr '/+' '_-' | tr -d '='


# tonos-cli -u https://main2.ton.dev run 0:32cbeb830976359f43ce3fcfbcec78fb81418aacda688b9a03fedc3f4de2d007 getInvokeMessage "{\"egree_address\":\"0:d7b6a9a90dd4d4e20b70476d33496be4d7a0f2d56bd41207afb43184b414b9ed\"}"  --abi app/debot/egree-debot.abi.json 
