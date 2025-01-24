Decentralized Insurance Protocol
This repository contains the Clarity smart contract for a decentralized insurance protocol. The contract allows users to purchase insurance policies, file claims, and approve claims. The contract also maintains a pool balance to manage the funds.

Contract Overview
Data Variables
pool-balance: The total balance of the insurance pool.
policies: A map of user policies, storing the premium and validity status.
claims: A map of claims, storing the user, amount, and approval status.
Constants
ERR_POLICY_EXISTS: Error code for existing policy.
ERR_NO_POLICY: Error code for no policy found.
ERR_CLAIM_EXISTS: Error code for existing claim.
ERR_INVALID_CLAIM: Error code for invalid claim.
ERR_NOT_ENOUGH_BALANCE: Error code for insufficient balance.
ERR_INVALID_AMOUNT: Error code for invalid amount.
MAX_PREMIUM: Maximum premium amount.
MAX_CLAIM_AMOUNT: Maximum claim amount.
Public Functions
purchase-policy
Allows a user to purchase an insurance policy by paying a premium.

file-claim
Allows a user to file a claim.

approve-claim
Allows the contract owner to approve a claim.

Read-Only Functions
get-pool-balance
Returns the current pool balance.

get-policy
Returns the policy details for a given user.

get-claim
Returns the details of a claim.

Usage
Purchase Policy: Call the purchase-policy function with the desired premium amount.
File Claim: Call the file-claim function with a unique claim ID and the claim amount.
Approve Claim: The contract owner can call the approve-claim function with the claim ID to approve the claim.
Check Pool Balance: Call the get-pool-balance function to get the current pool balance.
Check Policy: Call the get-policy function with the user's principal to get the policy details.
Check Claim: Call the get-claim function with the claim ID to get the claim details.
