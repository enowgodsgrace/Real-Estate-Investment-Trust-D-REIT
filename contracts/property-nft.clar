;; Property NFT Contract

(define-non-fungible-token property uint)

(define-data-var last-property-id uint u0)

(define-map property-details
  { property-id: uint }
  {
    address: (string-ascii 100),
    value: uint,
    rent-amount: uint,
    total-shares: uint
  }
)

(define-public (mint-property (address (string-ascii 100)) (value uint) (rent-amount uint) (total-shares uint))
  (let
    (
      (property-id (+ (var-get last-property-id) u1))
    )
    (try! (nft-mint? property property-id tx-sender))
    (map-set property-details
      { property-id: property-id }
      {
        address: address,
        value: value,
        rent-amount: rent-amount,
        total-shares: total-shares
      }
    )
    (var-set last-property-id property-id)
    (ok property-id)
  )
)

(define-read-only (get-property-details (property-id uint))
  (ok (unwrap! (map-get? property-details { property-id: property-id }) (err u404)))
)

(define-public (transfer (property-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u403))
    (try! (nft-transfer? property property-id sender recipient))
    (ok true)
  )
)

