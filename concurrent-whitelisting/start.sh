#!/bin/bash

display_usage() {
    echo "Missing $1 parameter. Please check if all parameters were specified."
    echo "Usage: start.sh [CHAIN_ID] [CHAIN_DIR] [RPC_PORT] [P2P_PORT] [PROFILING_PORT] [GRPC_PORT]"
    echo "Example: start.sh test-chain-id ./data 26657 26656 6060 9090"
    exit 1
}

BINARY=babylond

DENOM=bbn
BASEDENOM=ubbn
KEYRING=--keyring-backend="test"
SILENT=1

redirect() {
    if [ "$SILENT" -eq 1 ]; then
        "$@" >/dev/null 2>&1
    else
        "$@"
    fi
}

CHAINID=$1
CHAINDIR=$2
RPCPORT=$3
P2PPORT=$4
PROFPORT=$5
GRPCPORT=$6

if [ -z "$1" ]; then
    display_usage "[CHAIN_ID]"
fi

if [ -z "$2" ]; then
    display_usage "[CHAIN_DIR]"
fi

if [ -z "$3" ]; then
    display_usage "[RPC_PORT]"
fi

if [ -z "$4" ]; then
    display_usage "[P2P_PORT]"
fi

if [ -z "$5" ]; then
    display_usage "[PROFILING_PORT]"
fi

if [ -z "$6" ]; then
    display_usage "[GRPC_PORT]"
fi

# ensure the binary exists
if ! command -v $BINARY &>/dev/null; then
    echo "$BINARY could not be found"
    exit
fi

RPC_ENDPOINT="127.0.0.1:$RPCPORT"

# kill previous runs
echo "Killing $BINARY..."
killall $BINARY &>/dev/null

# Delete chain data from old runs
echo "Deleting $CHAINDIR/$CHAINID folders..."
rm -rf $CHAINDIR/$CHAINID &>/dev/null
rm $CHAINDIR/$CHAINID.log &>/dev/null

echo "Creating $BINARY instance: home=$CHAINDIR | chain-id=$CHAINID | p2p=:$P2PPORT | rpc=:$RPCPORT | profiling=:$PROFPORT | grpc=:$GRPCPORT"

# Add dir for chain, exit if error
if ! mkdir -p $CHAINDIR/$CHAINID 2>/dev/null; then
    echo "Failed to create chain folder. Aborting..."
    exit 1
fi

$BINARY testnet --v 1 --output-dir $CHAINDIR/$CHAINID --starting-ip-address 192.168.10.2 --keyring-backend test --chain-id $CHAINID --additional-sender-account true

# create a copy of the mnemonic for the relayer account
cp $CHAINDIR/$CHAINID/node0/babylond/additional_key_seed.json $CHAINDIR/$CHAINID/key_seed.json

# Check platform
platform='unknown'
unamestr=$(uname)
if [ "$unamestr" = 'Linux' ]; then
    platform='linux'
fi

# Set proper defaults and change ports (use a different sed for Mac or Linux)
echo "Change settings in config.toml and genesis.json files..."
if [ $platform = 'linux' ]; then
    sed -i 's#"tcp://0.0.0.0:26657"#"tcp://0.0.0.0:'"$RPCPORT"'"#g' $CHAINDIR/$CHAINID/node0/$BINARY/config/config.toml
    sed -i 's#"tcp://0.0.0.0:26656"#"tcp://0.0.0.0:'"$P2PPORT"'"#g' $CHAINDIR/$CHAINID/node0/$BINARY/config/config.toml
    sed -i 's#"localhost:6060"#"localhost:'"$PROFILINGPORT"'"#g' $CHAINDIR/$CHAINID/node0/$BINARY/config/config.toml
    sed -i 's/timeout_commit = "5s"/timeout_commit = "1s"/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/config.toml
    sed -i 's/timeout_propose = "3s"/timeout_propose = "1s"/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/config.toml
    sed -i 's/index_all_keys = false/index_all_keys = true/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/config.toml
    sed -i 's/"bond_denom": "stake"/"bond_denom": "'"$DENOM"'"/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/genesis.json
    sed -i 's/"voting_period": "172800s"/"voting_period": "40s"/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/genesis.json
    sed -i 's/"expedited_voting_period": "86400s"/"expedited_voting_period": "10s"/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/genesis.json
    sed -i 's/"secret"/"mnemonic"/g' $CHAINDIR/$CHAINID/key_seed.json
    # permissioned wasm integration
    sed -i 's/"permission": "Everybody"/"permission": "AnyOfAddresses"/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/genesis.json
    sed -i 's/"addresses": \[\]/"addresses": \["bbn10d07y265gmmuvt4z0w9aw880jnsr700jduz5f2"\]/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/genesis.json
else
    sed -i '' 's#"tcp://0.0.0.0:26657"#"tcp://0.0.0.0:'"$RPCPORT"'"#g' $CHAINDIR/$CHAINID/node0/$BINARY/config/config.toml
    sed -i '' 's#"tcp://0.0.0.0:26656"#"tcp://0.0.0.0:'"$P2PPORT"'"#g' $CHAINDIR/$CHAINID/node0/$BINARY/config/config.toml
    sed -i '' 's#"localhost:6060"#"localhost:'"$PROFILINGPORT"'"#g' $CHAINDIR/$CHAINID/node0/$BINARY/config/config.toml
    sed -i '' 's/timeout_commit = "5s"/timeout_commit = "1s"/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/config.toml
    sed -i '' 's/timeout_propose = "3s"/timeout_propose = "1s"/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/config.toml
    sed -i '' 's/index_all_keys = false/index_all_keys = true/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/config.toml
    sed -i '' 's/"bond_denom": "stake"/"bond_denom": "'"$DENOM"'"/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/genesis.json
    sed -i '' 's/"voting_period": "172800s"/"voting_period": "40s"/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/genesis.json
    sed -i '' 's/"expedited_voting_period": "86400s"/"expedited_voting_period": "10s"/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/genesis.json
    sed -i '' 's/"secret"/"mnemonic"/g' $CHAINDIR/$CHAINID/key_seed.json
    # permissioned wasm integration
    sed -i '' 's/"permission": "Everybody"/"permission": "AnyOfAddresses"/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/genesis.json
    sed -i '' 's/"addresses": \[\]/"addresses": \["bbn10d07y265gmmuvt4z0w9aw880jnsr700jduz5f2"\]/g' $CHAINDIR/$CHAINID/node0/$BINARY/config/genesis.json
fi

# Start the node
echo "start a Babylon node"
$BINARY --home $CHAINDIR/$CHAINID/node0/$BINARY start --pruning=nothing --grpc-web.enable=false --grpc.address="0.0.0.0:$GRPCPORT" >$CHAINDIR/$CHAINID.log 2>&1 &

# Wait for the node to start
sleep 10

wasm_params=$(babylond query wasm params --node tcp://$RPC_ENDPOINT -o json)
echo "The current wasm params is $wasm_params"
echo ""

# Submit software upgrade proposals
echo "Submitting parameter update proposal 1..."
$BINARY --home $CHAINDIR/$CHAINID/node0/$BINARY tx gov submit-proposal ./draft_proposal.json --from test-spending-key $KEYRING --chain-id $CHAINID --fees 2000$BASEDENOM --yes

sleep 5

echo "Submitting parameter update proposal 2..."
$BINARY --home $CHAINDIR/$CHAINID/node0/$BINARY tx gov submit-proposal ./draft_proposal_2.json --from test-spending-key $KEYRING --chain-id $CHAINID --fees 2000$BASEDENOM --yes

# Wait for the proposal to be included in a block
sleep 5

# Validator votes for the proposal
echo "Voting for the parameter update proposal 1..."
$BINARY --home $CHAINDIR/$CHAINID/node0/$BINARY tx gov vote 1 yes --from node0 $KEYRING --chain-id $CHAINID --fees 2000$BASEDENOM --yes

sleep 5

echo "Voting for the parameter update proposal 2..."
$BINARY --home $CHAINDIR/$CHAINID/node0/$BINARY tx gov vote 2 yes --from node0 $KEYRING --chain-id $CHAINID --fees 2000$BASEDENOM --yes

# Wait for the voting period to end
sleep 10

# Check proposal status
while true; do
    status=$(babylond q gov proposal 1 --output json | jq '.proposal.status')
    if [ $status -lt 3 ]; then
        echo "Proposal has not been passed"
        sleep 5
    else
        echo "Proposal has been passed!"
        break
    fi
done

while true; do
    status=$(babylond q gov proposal 2 --output json | jq '.proposal.status')
    if [ $status -lt 3 ]; then
        echo "Proposal has not been passed"
        sleep 5
    else
        echo "Proposal has been passed!"
        break
    fi
done

# Check the wasm params after the proposal
while true; do
    wasm_params=$(babylond query wasm params --node tcp://$RPC_ENDPOINT -o json)
    echo "The wasm params after gov prop is $wasm_params"
    sleep 5
done
