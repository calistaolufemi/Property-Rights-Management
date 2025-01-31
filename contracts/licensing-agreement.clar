;; Licensing Agreement Contract

(define-map licensing-agreements
  { agreement-id: uint }
  {
    licensor: principal,
    licensee: principal,
    terms: (string-utf8 1000),
    start-date: uint,
    end-date: uint,
    royalty-rate: uint,
    status: (string-ascii 20)
  }
)

(define-data-var agreement-id-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_AGREEMENT (err u400))

(define-read-only (get-licensing-agreement (agreement-id uint))
  (map-get? licensing-agreements { agreement-id: agreement-id })
)

(define-public (create-licensing-agreement
    (licensee principal)
    (terms (string-utf8 1000))
    (duration uint)
    (royalty-rate uint))
  (let
    ((new-agreement-id (+ (var-get agreement-id-nonce) u1)))
    (map-set licensing-agreements
      { agreement-id: new-agreement-id }
      {
        licensor: tx-sender,
        licensee: licensee,
        terms: terms,
        start-date: block-height,
        end-date: (+ block-height duration),
        royalty-rate: royalty-rate,
        status: "Active"
      }
    )
    (var-set agreement-id-nonce new-agreement-id)
    (ok new-agreement-id)
  )
)

(define-public (terminate-agreement (agreement-id uint))
  (let
    ((agreement (unwrap! (get-licensing-agreement agreement-id) ERR_NOT_FOUND)))
    (asserts! (or (is-eq tx-sender (get licensor agreement)) (is-eq tx-sender (get licensee agreement))) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status agreement) "Active") ERR_INVALID_AGREEMENT)
    (map-set licensing-agreements
      { agreement-id: agreement-id }
      (merge agreement { status: "Terminated" })
    )
    (ok true)
  )
)

(define-read-only (get-all-licensing-agreements)
  (ok (var-get agreement-id-nonce))
)

