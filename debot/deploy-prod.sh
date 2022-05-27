#!/bin/bash
set -e

if [[ $1 != *".tvc"  ]] ; then 
    echo "ERROR: contract file name .tvc required!"
    echo ""
    echo "USAGE:"
    echo "  ${0} FILENAME NETWORK"
    echo "    where:"
    echo "      FILENAME - required, debot tvc file name"
    echo "      NETWORK  - optional, network endpoint, default is http://127.0.0.1"
    echo ""
    echo "PRIMER:"
    echo "  ${0} mydebot.tvc https://net.ton.dev"
    exit 1
fi

DEBOT_NAME=${1%.*}
NETWORK="${2:-https://main4.ton.dev}"
GIVER_ADDRESS=0:329a096a3dd224e7029a125a537503054df9a38c1954cb7b9f8e597fdb9edbcb

# Check if tonos-cli installed 
tos=./tonos-cli
if $tos --version > /dev/null 2>&1; then
    echo "OK $tos installed locally."
else 
    tos=tonos-cli
    if $tos --version > /dev/null 2>&1; then
        echo "OK $tos installed globally."
    else 
        echo "$tos not found globally or in the current directory. Please install it and rerun script."
    fi
fi

# function giver {
#  $tos --url $NETWORK call --abi local.abi.json $GIVER_ADDRESS sendGrams "{\"dest\":\"$1\",\"amount\":1,\"bounce\":false}"
# }
echo $NETWORK
function giver {
    $tos --url $NETWORK call \
        --abi giver.abi.json \
        --sign giver-prod.keys.json \
        $GIVER_ADDRESS \
        sendTransaction "{\"dest\":\"$1\",\"value\":1000000,\"bounce\":false}"
}

function get_address {
    echo $(cat $1.log | grep "Raw address:" | cut -d ' ' -f 3)
}

function genaddr {
    $tos genaddr $1.tvc $1.abi.json --genkey $1.keys.json > $1.log
}

echo "Step 1. Calculating debot address"
genaddr $DEBOT_NAME
# $tos genaddr $DEBOT_NAME.tvc $DEBOT_NAME.abi.json --setkey $DEBOT_NAME.keys.json > $DEBOT_NAME.log
DEBOT_ADDRESS=$(get_address $DEBOT_NAME)

echo "Step 2. Sending tokens to address: $DEBOT_ADDRESS"
giver $DEBOT_ADDRESS
DEBOT_ABI=$(cat $DEBOT_NAME.abi.json | xxd -ps -c 20000)


echo "Step 3. Deploying contract"
$tos --url $NETWORK deploy $DEBOT_NAME.tvc "{}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json 1>/dev/null

$tos --url $NETWORK call $DEBOT_ADDRESS setABI "{\"dabi\":\"$DEBOT_ABI\"}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json 1>/dev/null


# code=$(base64 -w 0 $DEBOT_NAME.tvc)

# $tos --url $NETWORK call $DEBOT_ADDRESS setCode "{\"code\":\"$code\"}" \
#     --sign $DEBOT_NAME.keys.json \
#     --abi $DEBOT_NAME.abi.json # 1>/dev/null

echo "Done! Deployed debot with address: $DEBOT_ADDRESS"