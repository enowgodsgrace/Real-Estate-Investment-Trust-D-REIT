;; Property Management Contract

(define-map proposals
  { proposal-id: uint }
  {
    description: (string-utf8 500),
    amount: uint,
    deadline: uint,
    approved: bool,
    executed: bool,
    votes-for: uint,
    votes-against: uint
  }
)

(define-data-var proposal-nonce uint u0)

(define-public (create-proposal (description (string-utf8 500)) (amount uint) (deadline uint))
  (let
    (
      (proposal-id (+ (var-get proposal-nonce) u1))
    )
    (map-set proposals
      { proposal-id: proposal-id }
      {
        description: description,
        amount: amount,
        deadline: deadline,
        approved: false,
        executed: false,
        votes-for: u0,
        votes-against: u0
      }
    )
    (var-set proposal-nonce proposal-id)
    (ok proposal-id)
  )
)

(define-public (vote-on-proposal (proposal-id uint) (in-favor bool))
  (let
    (
      (proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) (err u404)))
    )
    (if in-favor
      (map-set proposals
        { proposal-id: proposal-id }
        (merge proposal { votes-for: (+ (get votes-for proposal) u1) })
      )
      (map-set proposals
        { proposal-id: proposal-id }
        (merge proposal { votes-against: (+ (get votes-against proposal) u1) })
      )
    )
    (ok true)
  )
)

(define-public (execute-proposal (proposal-id uint))
  (let
    (
      (proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) (err u404)))
    )
    (asserts! (>= block-height (get deadline proposal)) (err u401))
    (asserts! (not (get executed proposal)) (err u402))
    (if (proposal-approved proposal)
      (begin
        (try! (as-contract (stx-transfer? (get amount proposal) tx-sender (as-contract tx-sender))))
        (map-set proposals { proposal-id: proposal-id } (merge proposal { approved: true, executed: true }))
        (ok true)
      )
      (begin
        (map-set proposals { proposal-id: proposal-id } (merge proposal { approved: false, executed: true }))
        (ok false)
      )
    )
  )
)

(define-private (proposal-approved (proposal { description: (string-utf8 500), amount: uint, deadline: uint, approved: bool, executed: bool, votes-for: uint, votes-against: uint }))
  (> (* (get votes-for proposal) u100) (* (+ (get votes-for proposal) (get votes-against proposal)) u50))
)

(define-public (withdraw-funds (amount uint))
  (begin
    (try! (as-contract (stx-transfer? amount (as-contract tx-sender) tx-sender)))
    (ok true)
  )
)

