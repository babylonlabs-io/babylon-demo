# Whitelisting Address Governance Proposal Example

This example demonstrates how to submit and vote on a governance proposal to whitelist an address for code upload permissions in Babylon.

## Overview

The example:

1. Starts a local Babylon testnet
2. Submits a governance proposal to add an address to the code upload whitelist
3. Votes on the proposal
4. Waits for the proposal to pass
5. Verifies the updated parameters

## Files

- `start.sh` - Script to start a local testnet and run the example
- `draft_proposal.json` - The governance proposal to whitelist an address (following [this example](https://www.mintscan.io/osmosis/proposals/913))

## Execution

```bash
./start.sh test-chain-id ./data 26657 26656 6060 9090
```
