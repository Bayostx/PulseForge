;; PulseForge - Milestone-Powered Decentralized Crowdfunding with Multi-Token Support
;; A crowdfunding protocol where fund release is conditional on milestone achievements
;; Now supports STX and SIP-010 fungible tokens

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

;; Token type constants
(define-constant token-type-stx u0)
(define-constant token-type-sip010 u1)

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
    target-block: uint,
    required-votes: uint,
    current-votes: uint,
    is-completed: bool,
    funds-released: uint
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

;; Add milestone to campaign
(define-public (add-milestone (campaign-id uint) (description (string-ascii 200)) (target-block uint) (required-votes uint))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) err-not-found))
        (milestone-id (var-get next-milestone-id)))
    (asserts! (is-eq (get creator campaign) tx-sender) err-unauthorized)
    (asserts! (get is-active campaign) err-campaign-ended)
    (asserts! (> target-block stacks-block-height) err-invalid-milestone)
    (asserts! (> required-votes u0) err-invalid-amount)
    (asserts! (> (len description) u0) err-invalid-amount)
    
    (map-set milestones {campaign-id: campaign-id, milestone-id: milestone-id} {
      description: description,
      target-block: target-block,
      required-votes: required-votes,
      current-votes: u0,
      is-completed: false,
      funds-released: u0
    })
    
    (map-set campaigns campaign-id (merge campaign {milestones-count: (+ (get milestones-count campaign) u1)}))
    (var-set next-milestone-id (+ milestone-id u1))
    (ok milestone-id)
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

;; Vote for milestone completion
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
    (asserts! (>= (get current-votes milestone) (get required-votes milestone)) err-insufficient-votes)
    
    (let ((release-amount (/ (get raised-amount campaign) (get milestones-count campaign))))
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
    (asserts! (>= (get current-votes milestone) (get required-votes milestone)) err-insufficient-votes)
    
    (let ((release-amount (/ (get raised-amount campaign) (get milestones-count campaign))))
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