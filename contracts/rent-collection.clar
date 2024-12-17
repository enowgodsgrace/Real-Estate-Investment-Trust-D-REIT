;; Rent Collection Contract

(define-map rent-payments
  { property-id: uint, month: uint, year: uint }
  { amount: uint, distributed: bool }
)

(define-map property-owners
  { property-id: uint }
  { owner: principal }
)

(define-public (collect-rent (property-id uint) (month uint) (year uint) (amount uint))
  (begin
    (map-set rent-payments
      { property-id: property-id, month: month, year: year }
      { amount: amount, distributed: false }
    )
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (ok true)
  )
)

(define-public (distribute-rent (property-id uint) (month uint) (year uint))
  (let
    (
      (rent-payment (unwrap! (map-get? rent-payments { property-id: property-id, month: month, year: year }) (err u404)))
      (owner (unwrap! (get owner (map-get? property-owners { property-id: property-id })) (err u405)))
    )
    (asserts! (not (get distributed rent-payment)) (err u401))
    (try! (as-contract (stx-transfer? (get amount rent-payment) tx-sender owner)))
    (map-set rent-payments
      { property-id: property-id, month: month, year: year }
      (merge rent-payment { distributed: true })
    )
    (ok true)
  )
)

(define-public (set-property-owner (property-id uint) (new-owner principal))
  (begin
    (map-set property-owners
      { property-id: property-id }
      { owner: new-owner }
    )
    (ok true)
  )
)

