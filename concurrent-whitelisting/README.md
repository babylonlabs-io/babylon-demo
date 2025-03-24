# Concurrent Whitelisting Test

This test demonstrates submitting and processing multiple governance proposals for whitelisting addresses concurrently.

## Overview

The test:

1. Starts a local Babylon chain with permissioned WASM enabled
2. Submits two governance proposals to whitelist different addresses for code upload
3. Votes on both proposals 
4. Verifies both proposals pass and the addresses are added to the whitelist

## Files

- `start.sh` - Main test script that:
  - Sets up and starts local chain
  - Submits the governance proposals
  - Handles voting and verification
- `draft_proposal.json` - First proposal to whitelist address 1
- `draft_proposal_2.json` - Second proposal to whitelist address 2
- `draft_metadata.json` - Metadata for first proposal
- `draft_metadata_2.json` - Metadata for second proposal
