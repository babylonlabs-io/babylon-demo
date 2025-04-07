# Babylon Demo

This repository provides demo examples for Babylon chain.

## Scenarios

**whitelisting-address-gov-prop** is a demo of passing a `MsgAddCodeUploadParamsAddresses` gov prop for whitelisting a single address.

The result: after the gov prop is passed, then the given address is whitelisted in the wasm module parameters.

**concurrent-whitelisting** is a demo of passing two `MsgAddCodeUploadParamsAddresses` gov props concurrently. 

The result: after two gov props are passed, both addresses are whitelisted in the wasm module parameters, without conflicting with each other.


## Usage
Change directory to the target scenario: 

`cd whitelisting-address-gov-prop` or `cd concurrent-whitelisting`

The start.sh script should be used with parameters: 

`start.sh [CHAIN_ID] [CHAIN_DIR] [RPC_PORT] [P2P_PORT] [PROFILING_PORT] [GRPC_PORT]`

For example: 

    ```shell
    sh start.sh test-chain-id ./data 26657 26656 6060 9090
    ```
Since it is a local deployment, the chain ID can be arbitrary. 

Console output will show relevant information related to proposals, voting, and parameter changes. 