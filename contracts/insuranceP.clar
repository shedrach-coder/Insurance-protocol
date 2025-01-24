;; contracts/insuranceP.clar
;; Decentralized Insurance Protocol - Clarity Smart Contract

;; Define data variables
(define-data-var pool-balance uint u0)
(define-map policies principal { premium: uint, valid: bool })
(define-map claims uint { user: principal, amount: uint, status: { approved: bool } })

;; Define constants for error codes
(define-constant ERR_POLICY_EXISTS u1)
(define-constant ERR_NO_POLICY u2)
(define-constant ERR_CLAIM_EXISTS u3)
(define-constant ERR_INVALID_CLAIM u4)
(define-constant ERR_NOT_ENOUGH_BALANCE u5)
(define-constant ERR_INVALID_AMOUNT u6)
(define-constant MAX_PREMIUM u1000000000) ;; Set maximum premium amount
(define-constant MAX_CLAIM_AMOUNT u1000000000) ;; Set maximum claim amount

;; Function to purchase an insurance policy
(define-public (purchase-policy (premium uint))
  (let ((contract-address (as-contract tx-sender)))
    (begin
      ;; Validate premium amount
      (asserts! (and (> premium u0) (<= premium MAX_PREMIUM)) (err ERR_INVALID_AMOUNT))
      
      ;; Ensure the user doesn't already have an active policy
      (asserts! (is-none (map-get? policies tx-sender)) (err ERR_POLICY_EXISTS))

      ;; Transfer the premium to the contract
      (try! (stx-transfer? premium tx-sender contract-address))

      ;; Store the user's policy in the map
      (map-set policies tx-sender { premium: premium, valid: true })

      ;; Increment the pool balance
      (var-set pool-balance (+ (var-get pool-balance) premium))

      (ok true)
    )
  )
)

;; Function to file a claim
(define-public (file-claim (claim-id uint) (amount uint))
  (begin
    ;; Validate claim amount
    (asserts! (and (> amount u0) (<= amount MAX_CLAIM_AMOUNT)) (err ERR_INVALID_AMOUNT))
    
    ;; Retrieve the user's policy
    (let ((policy (unwrap! (map-get? policies tx-sender) (err ERR_NO_POLICY))))
      ;; Ensure the policy exists and is valid
      (asserts! (get valid policy) (err ERR_NO_POLICY))

      ;; Ensure there isn't an existing claim with the same ID
      (asserts! (is-none (map-get? claims claim-id)) (err ERR_CLAIM_EXISTS))

      ;; Save the claim to the claims map
      (map-set claims claim-id { 
        user: tx-sender, 
        amount: amount, 
        status: { approved: false } 
      })

      (ok true)
    )
  )
)

;; Function to approve a claim
(define-public (approve-claim (claim-id uint))
  (let ((contract-address (as-contract tx-sender)))
    (begin
      ;; Retrieve and validate the claim
      (let ((claim (unwrap! (map-get? claims claim-id) (err ERR_INVALID_CLAIM))))
        ;; Ensure the claim is not already approved
        (asserts! (not (get approved (get status claim))) (err ERR_INVALID_CLAIM))

        ;; Check the pool balance
        (let ((claim-amount (get amount claim)))
          (asserts! (<= claim-amount (var-get pool-balance)) (err ERR_NOT_ENOUGH_BALANCE))

          ;; Deduct the amount from the pool balance
          (var-set pool-balance (- (var-get pool-balance) claim-amount))

          ;; Transfer the payout to the user
          (try! (stx-transfer? claim-amount contract-address (get user claim)))

          ;; Mark the claim as approved
          (map-set claims claim-id { 
            user: (get user claim), 
            amount: claim-amount, 
            status: { approved: true } 
          })

          (ok true)
        )
      )
    )
  )
)

;; Function to get the current pool balance
(define-read-only (get-pool-balance)
  (ok (var-get pool-balance))
)

;; Function to check a user's policy details
(define-read-only (get-policy (user principal))
  (ok (map-get? policies user))
)

;; Function to check the details of a claim
(define-read-only (get-claim (claim-id uint))
  (ok (map-get? claims claim-id))
)