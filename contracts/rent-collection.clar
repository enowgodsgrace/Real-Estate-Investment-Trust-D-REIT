;; Rent Collection Contract

(define-map rent-payments
  { property-id: uint, month: uint, year: uint }
  { amount: uint, distributed: bool }
)

(define-public (collect-rent (property-id uint) (month uint) (year uint))
  (let
    (
      (property (unwrap! (contract-call? .property-nft get-property-details property-id) (err u404)))
      (rent-amount (get rent-amount property))
    )
    (try! (stx-transfer? rent-amount tx-sender (as-contract tx-sender)))
    (map-set rent-payments
      { property-id: property-id, month: month, year: year }
      { amount: rent-amount, distributed: false }
    )
    (ok true)
  )
)

(define-public (distribute-rent (property-id uint) (month uint) (year uint))
  (let
    (
      (rent-payment (unwrap! (map-get? rent-payments { property-id: property-id, month: month, year: year }) (err u404)))
      (shares (unwrap! (map-get? property-shares { property-id: property-id }) (err u404)))
      (total-shares (get total-shares shares))
      (rent-amount (get amount rent-payment))
    )
    (asserts! (not (get distributed rent-payment)) (err u401))
    (map-set rent-payments
      { property-id: property-id, month: month, year: year }
      (merge rent-payment { distributed: true })
    )
    (distribute-to-shareholders property-id total-shares rent-amount)
    (ok true)
  )
)

(define-private (distribute-to-shareholders (property-id uint) (total-shares uint) (rent-amount uint))
  (map-get? shareholder-balances { property-id: property-id, shareholder: tx-sender })
)

