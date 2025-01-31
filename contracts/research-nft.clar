;; Research NFT Contract

(define-non-fungible-token research-nft uint)

(define-map token-data
  { token-id: uint }
  {
    token-type: (string-ascii 20),
    researcher: principal,
    creation-date: uint
  }
)

(define-data-var token-id-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))

(define-read-only (get-last-token-id)
  (ok (var-get token-id-nonce))
)

(define-read-only (get-token-uri (token-id uint))
  (ok none)
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? research-nft token-id))
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
    (nft-transfer? research-nft token-id sender recipient)
  )
)

(define-public (mint-research-nft (token-type (string-ascii 20)))
  (let
    ((new-token-id (+ (var-get token-id-nonce) u1)))
    (try! (nft-mint? research-nft new-token-id tx-sender))
    (map-set token-data
      { token-id: new-token-id }
      {
        token-type: token-type,
        researcher: tx-sender,
        creation-date: block-height
      }
    )
    (var-set token-id-nonce new-token-id)
    (ok new-token-id)
  )
)

(define-read-only (get-token-data (token-id uint))
  (map-get? token-data { token-id: token-id })
)

