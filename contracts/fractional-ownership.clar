;; Fractional Ownership Contract

(define-fungible-token property-share)

(define-map property-shares
  { property-id: uint }
  { total-shares: uint, available-shares: uint }
)

(define-map shareholder-balances
  { property-id: uint, shareholder: principal }
  { shares: uint }
)

(define-public (create-shares (property-id uint) (total-shares uint))
  (let
    (
      (property (unwrap! (contract-call? .property-nft get-property-details property-id) (err u404)))
    )
    (asserts! (is-eq (get total-shares property) total-shares) (err u401))
    (map-set property-shares
      { property-id: property-id }
      { total-shares: total-shares, available-shares: total-shares }
    )
    (ok true)
  )
)

(define-public (buy-shares (property-id uint) (amount uint))
  (let
    (
      (shares (unwrap! (map-get? property-shares { property-id: property-id }) (err u404)))
      (available (get available-shares shares))
    )
    (asserts! (<= amount available) (err u401))
    (try! (ft-mint? property-share amount tx-sender))
    (map-set property-shares
      { property-id: property-id }
      (merge shares { available-shares: (- available amount) })
    )
    (map-set shareholder-balances
      { property-id: property-id, shareholder: tx-sender }
      { shares: (+ (default-to u0 (get shares (map-get? shareholder-balances { property-id: property-id, shareholder: tx-sender }))) amount) }
    )
    (ok true)
  )
)

(define-read-only (get-shares (property-id uint) (shareholder principal))
  (ok (get shares (default-to { shares: u0 } (map-get? shareholder-balances { property-id: property-id, shareholder: shareholder }))))
)

