;; PulseForge - Milestone-Powered Decentralized Crowdfunding with Multi-Token Support
;; A crowdfunding protocol where fund release is conditional on milestone achievements
;; Now supports STX, SIP-010 fungible tokens, and advanced milestone types with automated verification

;; Define SIP-010 trait locally for development
(define-trait sip-010-trait
  (
    ;; Transfer from the caller to a new principal
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    
    ;; Get the token name
    (get-name () (response (string-ascii 32) uint))
    
    ;; Get the token symbol
    (get-symbol () (response (string-ascii 32) uint))
    
    ;; Get the number of decimal places
    (get-decimals () (response uint uint))
    
    ;; Get the balance of the specified owner
    (get-balance (principal) (response uint uint))
    
    ;; Get the total supply of tokens
    (get-total-supply () (response uint uint))
    
    ;; Get the token URI containing metadata
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  )
)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-campaign-ended (err u104))
(define-constant err-campaign-not-ended (err u105))
(define-constant err-already-voted (err u106))
(define-constant err-milestone-not-ready (err u107))
(define-constant err-insufficient-votes (err u108))
(define-constant err-already-backed (err u109))
(define-constant err-invalid-milestone (err u110))
(define-constant err-invalid-token (err u111))
(define-constant err-token-transfer-failed (err u112))
(define-constant err-condition-not-met (err u113))
(define-constant err-invalid-milestone-type (err u114))
(define-constant err-invalid-condition (err u115))
(define-constant err-milestone-dependency-not-met (err u116))

;; Token type constants
(define-constant token-type-stx u0)
(define-constant token-type-sip010 u1)

;; Milestone type constants
(define-constant milestone-type-manual u0)
(define-constant milestone-type-time-locked u1)
(define-constant milestone-type-funding-threshold u2)
(define-constant milestone-type-conditional u3)
(define-constant milestone-type-multi-dependency u4)

;; Data Variables
(define-data-var next-campaign-id uint u1)
(define-data-var next-milestone-id uint u1)

;; Data Maps
(define-map campaigns 
  uint 
  {
    creator: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    target-amount: uint,
    raised-amount: uint,
    end-block: uint,
    is-active: bool,
    milestones-count: uint,
    completed-milestones: uint,
    token-type: uint,
    token-contract: (optional principal)
  }
)

(define-map milestones
  {campaign-id: uint, milestone-id: uint}
  {
    description: (string-ascii 200),
    milestone-type: uint,
    target-block: uint,
    required-votes: uint,
    current-votes: uint,
    is-completed: bool,
    funds-released: uint,
    auto-verified: bool,
    condition-value: uint,
    dependency-milestone: (optional uint)
  }
)

(define-map campaign-backers
  {campaign-id: uint, backer: principal}
  {
    amount: uint,
    can-vote: bool
  }
)

(define-map milestone-votes
  {campaign-id: uint, milestone-id: uint, voter: principal}
  bool
)

;; Approved SIP-010 tokens registry
(define-map approved-tokens principal bool)

;; Milestone verification tracking
(define-map milestone-verifications
  {campaign-id: uint, milestone-id: uint}
  {
    verification-block: uint,
    verification-data: uint
  }
)

;; Private Functions

;; Validate token contract
(define-private (is-approved-token (token-contract principal))
  (default-to false (map-get? approved-tokens token-contract))
)

;; Transfer STX tokens
(define-private (transfer-stx (amount uint) (from principal) (to principal))
  (stx-transfer? amount from to)
)

;; Transfer SIP-010 tokens
(define-private (transfer-sip010 (token-contract <sip-010-trait>) (amount uint) (from principal) (to principal))
  (contract-call? token-contract transfer amount from to none)
)

;; Validate milestone type
(define-private (is-valid-milestone-type (milestone-type uint))
  (or (is-eq milestone-type milestone-type-manual)
      (or (is-eq milestone-type milestone-type-time-locked)
          (or (is-eq milestone-type milestone-type-funding-threshold)
              (or (is-eq milestone-type milestone-type-conditional)
                  (is-eq milestone-type milestone-type-multi-dependency)))))
)

;; Check if milestone dependency is met
(define-private (is-dependency-met (campaign-id uint) (dependency-milestone-id uint))
  (match (map-get? milestones {campaign-id: campaign-id, milestone-id: dependency-milestone-id})
    milestone-data (get is-completed milestone-data)
    false
  )
)

;; Verify time-locked milestone
(define-private (verify-time-locked-milestone (target-block uint))
  (>= stacks-block-height target-block)
)

;; Verify funding threshold milestone
(define-private (verify-funding-threshold-milestone (campaign-id uint) (condition-value uint))
  (match (map-get? campaigns campaign-id)
    campaign-data (>= (get raised-amount campaign-data) condition-value)
    false
  )
)

;; Verify conditional milestone
(define-private (verify-conditional-milestone (campaign-id uint) (milestone-id uint) (condition-value uint))
  (match (map-get? milestone-verifications {campaign-id: campaign-id, milestone-id: milestone-id})
    verification-data (>= (get verification-data verification-data) condition-value)
    false
  )
)

;; Auto-verify milestone based on type
(define-private (auto-verify-milestone (campaign-id uint) (milestone-id uint) (milestone-data (tuple (description (string-ascii 200)) (milestone-type uint) (target-block uint) (required-votes uint) (current-votes uint) (is-completed bool) (funds-released uint) (auto-verified bool) (condition-value uint) (dependency-milestone (optional uint)))))
  (let ((milestone-type (get milestone-type milestone-data))
        (target-block (get target-block milestone-data))
        (condition-value (get condition-value milestone-data))
        (dependency-milestone (get dependency-milestone milestone-data)))
    (if (is-eq milestone-type milestone-type-time-locked)
        (verify-time-locked-milestone target-block)
        (if (is-eq milestone-type milestone-type-funding-threshold)
            (verify-funding-threshold-milestone campaign-id condition-value)
            (if (is-eq milestone-type milestone-type-conditional)
                (verify-conditional-milestone campaign-id milestone-id condition-value)
                (if (is-eq milestone-type milestone-type-multi-dependency)
                    (match dependency-milestone
                      dep-id (is-dependency-met campaign-id dep-id)
                      false
                    )
                    false))))
  )
)

;; Public Functions

;; Approve a SIP-010 token for use in campaigns (only contract owner)
(define-public (approve-token (token-contract principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-standard token-contract) err-invalid-token)
    (map-set approved-tokens token-contract true)
    (ok true)
  )
)

;; Remove approval for a SIP-010 token (only contract owner)
(define-public (remove-token-approval (token-contract principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-standard token-contract) err-invalid-token)
    (map-delete approved-tokens token-contract)
    (ok true)
  )
)

;; Create a new STX campaign
(define-public (create-stx-campaign (title (string-ascii 100)) (description (string-ascii 500)) (target-amount uint) (duration-blocks uint))
  (let ((campaign-id (var-get next-campaign-id)))
    (asserts! (> target-amount u0) err-invalid-amount)
    (asserts! (> duration-blocks u0) err-invalid-amount)
    (asserts! (> (len title) u0) err-invalid-amount)
    (asserts! (> (len description) u0) err-invalid-amount)
    (asserts! (<= duration-blocks u525600) err-invalid-amount) ;; Max 1 year in blocks
    (map-set campaigns campaign-id {
      creator: tx-sender,
      title: title,
      description: description,
      target-amount: target-amount,
      raised-amount: u0,
      end-block: (+ stacks-block-height duration-blocks),
      is-active: true,
      milestones-count: u0,
      completed-milestones: u0,
      token-type: token-type-stx,
      token-contract: none
    })
    (var-set next-campaign-id (+ campaign-id u1))
    (ok campaign-id)
  )
)

;; Create a new SIP-010 token campaign
(define-public (create-token-campaign (title (string-ascii 100)) (description (string-ascii 500)) (target-amount uint) (duration-blocks uint) (token-contract principal))
  (let ((campaign-id (var-get next-campaign-id)))
    (asserts! (> target-amount u0) err-invalid-amount)
    (asserts! (> duration-blocks u0) err-invalid-amount)
    (asserts! (> (len title) u0) err-invalid-amount)
    (asserts! (> (len description) u0) err-invalid-amount)
    (asserts! (<= duration-blocks u525600) err-invalid-amount) ;; Max 1 year in blocks
    (asserts! (is-approved-token token-contract) err-invalid-token)
    (map-set campaigns campaign-id {
      creator: tx-sender,
      title: title,
      description: description,
      target-amount: target-amount,
      raised-amount: u0,
      end-block: (+ stacks-block-height duration-blocks),
      is-active: true,
      milestones-count: u0,
      completed-milestones: u0,
      token-type: token-type-sip010,
      token-contract: (some token-contract)
    })
    (var-set next-campaign-id (+ campaign-id u1))
    (ok campaign-id)
  )
)

;; Add basic milestone to campaign (manual verification)
(define-public (add-milestone (campaign-id uint) (description (string-ascii 200)) (target-block uint) (required-votes uint))
  (add-advanced-milestone campaign-id description milestone-type-manual target-block required-votes u0 none)
)

;; Add advanced milestone with specific type and conditions
(define-public (add-advanced-milestone (campaign-id uint) (description (string-ascii 200)) (milestone-type uint) (target-block uint) (required-votes uint) (condition-value uint) (dependency-milestone (optional uint)))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) err-not-found))
        (milestone-id (var-get next-milestone-id)))
    (asserts! (is-eq (get creator campaign) tx-sender) err-unauthorized)
    (asserts! (get is-active campaign) err-campaign-ended)
    (asserts! (> target-block stacks-block-height) err-invalid-milestone)
    (asserts! (> required-votes u0) err-invalid-amount)
    (asserts! (> (len description) u0) err-invalid-amount)
    (asserts! (is-valid-milestone-type milestone-type) err-invalid-milestone-type)
    
    ;; Validate dependency if provided
    (match dependency-milestone
      dep-id (asserts! (is-some (map-get? milestones {campaign-id: campaign-id, milestone-id: dep-id})) err-invalid-condition)
      true
    )
    
    ;; Validate condition value for specific milestone types
    (if (or (is-eq milestone-type milestone-type-funding-threshold)
            (is-eq milestone-type milestone-type-conditional))
        (asserts! (> condition-value u0) err-invalid-condition)
        true
    )
    
    (map-set milestones {campaign-id: campaign-id, milestone-id: milestone-id} {
      description: description,
      milestone-type: milestone-type,
      target-block: target-block,
      required-votes: required-votes,
      current-votes: u0,
      is-completed: false,
      funds-released: u0,
      auto-verified: false,
      condition-value: condition-value,
      dependency-milestone: dependency-milestone
    })
    
    (map-set campaigns campaign-id (merge campaign {milestones-count: (+ (get milestones-count campaign) u1)}))
    (var-set next-milestone-id (+ milestone-id u1))
    (ok milestone-id)
  )
)

;; Set verification data for conditional milestones (only creator)
(define-public (set-milestone-verification (campaign-id uint) (milestone-id uint) (verification-data uint))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) err-not-found))
        (milestone (unwrap! (map-get? milestones {campaign-id: campaign-id, milestone-id: milestone-id}) err-not-found)))
    (asserts! (is-eq (get creator campaign) tx-sender) err-unauthorized)
    (asserts! (is-eq (get milestone-type milestone) milestone-type-conditional) err-invalid-milestone-type)
    (asserts! (not (get is-completed milestone)) err-milestone-not-ready)
    (asserts! (> verification-data u0) err-invalid-amount)
    
    (map-set milestone-verifications {campaign-id: campaign-id, milestone-id: milestone-id} {
      verification-block: stacks-block-height,
      verification-data: verification-data
    })
    (ok true)
  )
)

;; Back a STX campaign
(define-public (back-stx-campaign (campaign-id uint) (amount uint))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) err-not-found)))
    (asserts! (get is-active campaign) err-campaign-ended)
    (asserts! (< stacks-block-height (get end-block campaign)) err-campaign-ended)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (is-eq (get token-type campaign) token-type-stx) err-invalid-token)
    (asserts! (is-none (map-get? campaign-backers {campaign-id: campaign-id, backer: tx-sender})) err-already-backed)
    
    (try! (transfer-stx amount tx-sender (as-contract tx-sender)))
    
    (map-set campaign-backers {campaign-id: campaign-id, backer: tx-sender} {
      amount: amount,
      can-vote: true
    })
    
    (map-set campaigns campaign-id (merge campaign {raised-amount: (+ (get raised-amount campaign) amount)}))
    (ok true)
  )
)

;; Back a SIP-010 token campaign
(define-public (back-token-campaign (campaign-id uint) (amount uint) (token-contract <sip-010-trait>))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) err-not-found))
        (campaign-token-contract (unwrap! (get token-contract campaign) err-invalid-token)))
    (asserts! (get is-active campaign) err-campaign-ended)
    (asserts! (< stacks-block-height (get end-block campaign)) err-campaign-ended)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (is-eq (get token-type campaign) token-type-sip010) err-invalid-token)
    (asserts! (is-eq (contract-of token-contract) campaign-token-contract) err-invalid-token)
    (asserts! (is-none (map-get? campaign-backers {campaign-id: campaign-id, backer: tx-sender})) err-already-backed)
    
    (match (transfer-sip010 token-contract amount tx-sender (as-contract tx-sender))
      success (begin
        (map-set campaign-backers {campaign-id: campaign-id, backer: tx-sender} {
          amount: amount,
          can-vote: true
        })
        (map-set campaigns campaign-id (merge campaign {raised-amount: (+ (get raised-amount campaign) amount)}))
        (ok true)
      )
      error err-token-transfer-failed
    )
  )
)

;; Vote for milestone completion with automatic verification check
(define-public (vote-milestone (campaign-id uint) (milestone-id uint))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) err-not-found))
        (milestone (unwrap! (map-get? milestones {campaign-id: campaign-id, milestone-id: milestone-id}) err-not-found))
        (backer-info (unwrap! (map-get? campaign-backers {campaign-id: campaign-id, backer: tx-sender}) err-unauthorized))
        (milestone-key {campaign-id: campaign-id, milestone-id: milestone-id})
        (vote-key {campaign-id: campaign-id, milestone-id: milestone-id, voter: tx-sender}))
    
    (asserts! (get can-vote backer-info) err-unauthorized)
    (asserts! (not (get is-completed milestone)) err-milestone-not-ready)
    (asserts! (>= stacks-block-height (get target-block milestone)) err-milestone-not-ready)
    (asserts! (is-none (map-get? milestone-votes vote-key)) err-already-voted)
    
    ;; Check dependency if milestone has one
    (match (get dependency-milestone milestone)
      dep-id (asserts! (is-dependency-met campaign-id dep-id) err-milestone-dependency-not-met)
      true
    )
    
    ;; Check if milestone can be auto-verified
    (let ((can-auto-verify (auto-verify-milestone campaign-id milestone-id milestone)))
      (if (and (not (is-eq (get milestone-type milestone) milestone-type-manual)) can-auto-verify)
          ;; Auto-verify if conditions are met
          (map-set milestones milestone-key (merge milestone {auto-verified: true}))
          ;; Manual verification required - check if conditions are met for automatic milestone types
          (if (not (is-eq (get milestone-type milestone) milestone-type-manual))
              (asserts! can-auto-verify err-condition-not-met)
              true)
      )
    )
    
    (map-set milestone-votes vote-key true)
    (map-set milestones milestone-key 
      (merge milestone {current-votes: (+ (get current-votes milestone) u1)}))
    (ok true)
  )
)

;; Release funds for completed milestone (STX campaigns)
(define-public (release-stx-milestone-funds (campaign-id uint) (milestone-id uint))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) err-not-found))
        (milestone (unwrap! (map-get? milestones {campaign-id: campaign-id, milestone-id: milestone-id}) err-not-found))
        (milestone-key {campaign-id: campaign-id, milestone-id: milestone-id}))
    
    (asserts! (is-eq (get creator campaign) tx-sender) err-unauthorized)
    (asserts! (is-eq (get token-type campaign) token-type-stx) err-invalid-token)
    (asserts! (not (get is-completed milestone)) err-milestone-not-ready)
    (asserts! (> (get milestones-count campaign) u0) err-invalid-milestone)
    
    ;; Check if milestone meets release criteria (votes or auto-verification)
    (asserts! (or (>= (get current-votes milestone) (get required-votes milestone))
                  (get auto-verified milestone)) err-insufficient-votes)
    
    (let ((release-amount (/ (get raised-amount campaign) (get milestones-count campaign))))
      (asserts! (> release-amount u0) err-invalid-amount)
      (try! (as-contract (transfer-stx release-amount tx-sender (get creator campaign))))
      
      (map-set milestones milestone-key
        (merge milestone {is-completed: true, funds-released: release-amount}))
      
      (map-set campaigns campaign-id 
        (merge campaign {completed-milestones: (+ (get completed-milestones campaign) u1)}))
      
      (ok release-amount)
    )
  )
)

;; Release funds for completed milestone (SIP-010 token campaigns)
(define-public (release-token-milestone-funds (campaign-id uint) (milestone-id uint) (token-contract <sip-010-trait>))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) err-not-found))
        (milestone (unwrap! (map-get? milestones {campaign-id: campaign-id, milestone-id: milestone-id}) err-not-found))
        (milestone-key {campaign-id: campaign-id, milestone-id: milestone-id})
        (campaign-token-contract (unwrap! (get token-contract campaign) err-invalid-token)))
    
    (asserts! (is-eq (get creator campaign) tx-sender) err-unauthorized)
    (asserts! (is-eq (get token-type campaign) token-type-sip010) err-invalid-token)
    (asserts! (is-eq (contract-of token-contract) campaign-token-contract) err-invalid-token)
    (asserts! (not (get is-completed milestone)) err-milestone-not-ready)
    (asserts! (> (get milestones-count campaign) u0) err-invalid-milestone)
    
    ;; Check if milestone meets release criteria (votes or auto-verification)
    (asserts! (or (>= (get current-votes milestone) (get required-votes milestone))
                  (get auto-verified milestone)) err-insufficient-votes)
    
    (let ((release-amount (/ (get raised-amount campaign) (get milestones-count campaign))))
      (asserts! (> release-amount u0) err-invalid-amount)
      (match (as-contract (transfer-sip010 token-contract release-amount tx-sender (get creator campaign)))
        success (begin
          (map-set milestones milestone-key
            (merge milestone {is-completed: true, funds-released: release-amount}))
          
          (map-set campaigns campaign-id 
            (merge campaign {completed-milestones: (+ (get completed-milestones campaign) u1)}))
          
          (ok release-amount)
        )
        error err-token-transfer-failed
      )
    )
  )
)

;; Request refund if STX campaign fails
(define-public (request-stx-refund (campaign-id uint))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) err-not-found))
        (backer-info (unwrap! (map-get? campaign-backers {campaign-id: campaign-id, backer: tx-sender}) err-unauthorized)))
    
    (asserts! (is-eq (get token-type campaign) token-type-stx) err-invalid-token)
    (asserts! (or (>= stacks-block-height (get end-block campaign)) (not (get is-active campaign))) err-campaign-not-ended)
    (asserts! (< (get raised-amount campaign) (get target-amount campaign)) err-campaign-not-ended)
    (asserts! (> (get amount backer-info) u0) err-invalid-amount)
    
    (try! (as-contract (transfer-stx (get amount backer-info) tx-sender tx-sender)))
    (map-delete campaign-backers {campaign-id: campaign-id, backer: tx-sender})
    (ok (get amount backer-info))
  )
)

;; Request refund if SIP-010 token campaign fails
(define-public (request-token-refund (campaign-id uint) (token-contract <sip-010-trait>))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) err-not-found))
        (backer-info (unwrap! (map-get? campaign-backers {campaign-id: campaign-id, backer: tx-sender}) err-unauthorized))
        (campaign-token-contract (unwrap! (get token-contract campaign) err-invalid-token)))
    
    (asserts! (is-eq (get token-type campaign) token-type-sip010) err-invalid-token)
    (asserts! (is-eq (contract-of token-contract) campaign-token-contract) err-invalid-token)
    (asserts! (or (>= stacks-block-height (get end-block campaign)) (not (get is-active campaign))) err-campaign-not-ended)
    (asserts! (< (get raised-amount campaign) (get target-amount campaign)) err-campaign-not-ended)
    (asserts! (> (get amount backer-info) u0) err-invalid-amount)
    
    (match (as-contract (transfer-sip010 token-contract (get amount backer-info) tx-sender tx-sender))
      success (begin
        (map-delete campaign-backers {campaign-id: campaign-id, backer: tx-sender})
        (ok (get amount backer-info))
      )
      error err-token-transfer-failed
    )
  )
)

;; End campaign (only by creator)
(define-public (end-campaign (campaign-id uint))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) err-not-found)))
    (asserts! (is-eq (get creator campaign) tx-sender) err-unauthorized)
    (asserts! (get is-active campaign) err-campaign-ended)
    
    (map-set campaigns campaign-id (merge campaign {is-active: false}))
    (ok true)
  )
)

;; Read-only functions

(define-read-only (get-campaign (campaign-id uint))
  (map-get? campaigns campaign-id)
)

(define-read-only (get-milestone (campaign-id uint) (milestone-id uint))
  (map-get? milestones {campaign-id: campaign-id, milestone-id: milestone-id})
)

(define-read-only (get-milestone-verification (campaign-id uint) (milestone-id uint))
  (map-get? milestone-verifications {campaign-id: campaign-id, milestone-id: milestone-id})
)

(define-read-only (get-backer-info (campaign-id uint) (backer principal))
  (map-get? campaign-backers {campaign-id: campaign-id, backer: backer})
)

(define-read-only (has-voted (campaign-id uint) (milestone-id uint) (voter principal))
  (default-to false (map-get? milestone-votes {campaign-id: campaign-id, milestone-id: milestone-id, voter: voter}))
)

(define-read-only (get-next-campaign-id)
  (var-get next-campaign-id)
)

(define-read-only (get-next-milestone-id)
  (var-get next-milestone-id)
)

(define-read-only (is-token-approved (token-contract principal))
  (is-approved-token token-contract)
)

(define-read-only (can-milestone-auto-verify (campaign-id uint) (milestone-id uint))
  (match (map-get? milestones {campaign-id: campaign-id, milestone-id: milestone-id})
    milestone-data (auto-verify-milestone campaign-id milestone-id milestone-data)
    false
  )
)

(define-read-only (get-milestone-dependency-status (campaign-id uint) (milestone-id uint))
  (match (map-get? milestones {campaign-id: campaign-id, milestone-id: milestone-id})
    milestone-data (match (get dependency-milestone milestone-data)
                     dep-id {dependency-id: (some dep-id), is-met: (is-dependency-met campaign-id dep-id)}
                     {dependency-id: none, is-met: true}
                   )
    {dependency-id: none, is-met: false}
  )
)
