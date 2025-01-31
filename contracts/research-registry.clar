;; Research Registry Contract

(define-map research-entries
  { entry-id: uint }
  {
    researcher: principal,
    title: (string-utf8 200),
    abstract: (string-utf8 1000),
    publication-date: uint,
    doi: (optional (string-ascii 50)),
    patent-pending: bool
  }
)

(define-map research-metadata
  { entry-id: uint }
  {
    keywords: (list 10 (string-ascii 50)),
    field-of-study: (string-ascii 100),
    funding-source: (optional (string-utf8 200)),
    additional-data: (optional (string-utf8 1000))
  }
)

(define-data-var entry-id-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u403))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_ALREADY_EXISTS (err u409))

(define-read-only (get-research-entry (entry-id uint))
  (map-get? research-entries { entry-id: entry-id })
)

(define-read-only (get-research-metadata (entry-id uint))
  (map-get? research-metadata { entry-id: entry-id })
)

(define-public (register-research
    (title (string-utf8 200))
    (abstract (string-utf8 1000))
    (doi (optional (string-ascii 50)))
    (patent-pending bool)
    (keywords (list 10 (string-ascii 50)))
    (field-of-study (string-ascii 100))
    (funding-source (optional (string-utf8 200)))
    (additional-data (optional (string-utf8 1000))))
  (let
    ((new-entry-id (+ (var-get entry-id-nonce) u1)))
    (map-set research-entries
      { entry-id: new-entry-id }
      {
        researcher: tx-sender,
        title: title,
        abstract: abstract,
        publication-date: block-height,
        doi: doi,
        patent-pending: patent-pending
      }
    )
    (map-set research-metadata
      { entry-id: new-entry-id }
      {
        keywords: keywords,
        field-of-study: field-of-study,
        funding-source: funding-source,
        additional-data: additional-data
      }
    )
    (var-set entry-id-nonce new-entry-id)
    (ok new-entry-id)
  )
)

(define-public (update-research-status (entry-id uint) (new-doi (optional (string-ascii 50))) (new-patent-pending bool))
  (let
    ((entry (unwrap! (get-research-entry entry-id) ERR_NOT_FOUND)))
    (asserts! (is-eq (get researcher entry) tx-sender) ERR_UNAUTHORIZED)
    (map-set research-entries
      { entry-id: entry-id }
      (merge entry {
        doi: (if (is-some new-doi) new-doi (get doi entry)),
        patent-pending: new-patent-pending
      })
    )
    (ok true)
  )
)

(define-read-only (get-all-research-entries)
  (ok (var-get entry-id-nonce))
)

