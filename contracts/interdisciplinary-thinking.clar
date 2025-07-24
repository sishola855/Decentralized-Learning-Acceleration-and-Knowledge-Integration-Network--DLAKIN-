;; Interdisciplinary Thinking Development Contract
;; Builds ability to connect insights across different fields

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-INVALID-INPUT (err u501))
(define-constant ERR-CONNECTION-NOT-FOUND (err u502))
(define-constant ERR-INSUFFICIENT-EXPERTISE (err u503))
(define-constant ERR-DUPLICATE-CONNECTION (err u504))
(define-constant ERR-INSIGHT-NOT-FOUND (err u505))

;; Data Variables
(define-data-var connection-counter uint u0)
(define-data-var insight-counter uint u0)
(define-data-var bridge-counter uint u0)
(define-data-var min-expertise-threshold uint u50)

;; Data Maps
(define-map domain-expertise
  { user: principal, domain: (string-ascii 50) }
  {
    expertise-level: uint,
    knowledge-depth: uint,
    practical-experience: uint,
    theoretical-understanding: uint,
    last-updated: uint,
    verified-by-peers: uint,
    contribution-score: uint
  }
)

(define-map cross-domain-connections
  { connection-id: uint }
  {
    creator: principal,
    source-domain: (string-ascii 50),
    target-domain: (string-ascii 50),
    connection-type: (string-ascii 50),
    strength-score: uint,
    validation-count: uint,
    insight-description: (string-ascii 500),
    practical-applications: (string-ascii 300),
    created-at: uint,
    verified: bool
  }
)

(define-map interdisciplinary-insights
  { insight-id: uint }
  {
    creator: principal,
    primary-domain: (string-ascii 50),
    secondary-domains: (list 5 (string-ascii 50)),
    insight-title: (string-ascii 150),
    insight-content: (string-ascii 1000),
    novelty-score: uint,
    impact-potential: uint,
    peer-reviews: uint,
    implementation-examples: uint,
    timestamp: uint,
    validated: bool
  }
)

(define-map domain-bridges
  { bridge-id: uint }
  {
    bridge-builder: principal,
    connected-domains: (list 10 (string-ascii 50)),
    bridge-methodology: (string-ascii 200),
    success-metrics: (list 5 uint),
    applications-developed: uint,
    collaboration-count: uint,
    innovation-score: uint,
    sustainability-rating: uint,
    created-at: uint,
    active: bool
  }
)

(define-map thinking-patterns
  { user: principal }
  {
    pattern-recognition-score: uint,
    analogical-thinking-level: uint,
    synthesis-capability: uint,
    creative-connections: uint,
    domain-fluidity: uint,
    innovation-index: uint,
    collaboration-effectiveness: uint,
    last-assessment: uint
  }
)

(define-map collaboration-networks
  { network-id: uint }
  {
    initiator: principal,
    participants: (list 20 principal),
    focus-domains: (list 8 (string-ascii 50)),
    shared-insights: uint,
    breakthrough-count: uint,
    network-strength: uint,
    knowledge-flow-rate: uint,
    created-at: uint,
    active: bool
  }
)

;; Private Functions
(define-private (calculate-connection-strength (source-expertise uint) (target-expertise uint) (validation-count uint))
  (let (
    (expertise-factor (/ (+ source-expertise target-expertise) u2))
    (validation-bonus (* validation-count u5))
    (base-strength (+ expertise-factor validation-bonus))
  )
    (if (> base-strength u100) u100 base-strength)
  )
)

(define-private (update-thinking-patterns (user principal) (connection-type (string-ascii 50)))
  (let (
    (current-patterns (default-to
      { pattern-recognition-score: u0, analogical-thinking-level: u0, synthesis-capability: u0,
        creative-connections: u0, domain-fluidity: u0, innovation-index: u0,
        collaboration-effectiveness: u0, last-assessment: u0 }
      (map-get? thinking-patterns { user: user })
    ))
    (pattern-boost (if (is-eq connection-type "analogical") u3 u1))
    (synthesis-boost (if (is-eq connection-type "synthesis") u4 u1))
  )
    (map-set thinking-patterns
      { user: user }
      {
        pattern-recognition-score: (+ (get pattern-recognition-score current-patterns) pattern-boost),
        analogical-thinking-level: (+ (get analogical-thinking-level current-patterns) pattern-boost),
        synthesis-capability: (+ (get synthesis-capability current-patterns) synthesis-boost),
        creative-connections: (+ (get creative-connections current-patterns) u2),
        domain-fluidity: (+ (get domain-fluidity current-patterns) u1),
        innovation-index: (/ (+ (* (get innovation-index current-patterns) u9)
                               (+ pattern-boost synthesis-boost)) u10),
        collaboration-effectiveness: (get collaboration-effectiveness current-patterns),
        last-assessment: block-height
      }
    )
  )
)

(define-private (validate-domain-expertise (user principal) (domain (string-ascii 50)) (min-level uint))
  (match (map-get? domain-expertise { user: user, domain: domain })
    expertise (>= (get expertise-level expertise) min-level)
    false
  )
)

;; Public Functions
(define-public (establish-domain-expertise (domain (string-ascii 50)) (expertise-level uint)
                                          (knowledge-depth uint) (practical-experience uint))
  (begin
    (asserts! (> (len domain) u0) ERR-INVALID-INPUT)
    (asserts! (<= expertise-level u100) ERR-INVALID-INPUT)
    (asserts! (<= knowledge-depth u100) ERR-INVALID-INPUT)
    (asserts! (<= practical-experience u100) ERR-INVALID-INPUT)

    (map-set domain-expertise
      { user: tx-sender, domain: domain }
      {
        expertise-level: expertise-level,
        knowledge-depth: knowledge-depth,
        practical-experience: practical-experience,
        theoretical-understanding: (/ (+ expertise-level knowledge-depth) u2),
        last-updated: block-height,
        verified-by-peers: u0,
        contribution-score: u0
      }
    )

    (ok true)
  )
)

(define-public (create-cross-domain-connection (source-domain (string-ascii 50)) (target-domain (string-ascii 50))
                                              (connection-type (string-ascii 50)) (insight-description (string-ascii 500))
                                              (practical-applications (string-ascii 300)))
  (let (
    (connection-id (+ (var-get connection-counter) u1))
    (source-expertise (unwrap! (map-get? domain-expertise { user: tx-sender, domain: source-domain }) ERR-INSUFFICIENT-EXPERTISE))
    (target-expertise (unwrap! (map-get? domain-expertise { user: tx-sender, domain: target-domain }) ERR-INSUFFICIENT-EXPERTISE))
  )
    (asserts! (not (is-eq source-domain target-domain)) ERR-INVALID-INPUT)
    (asserts! (> (len connection-type) u0) ERR-INVALID-INPUT)
    (asserts! (> (len insight-description) u0) ERR-INVALID-INPUT)
    (asserts! (>= (get expertise-level source-expertise) (var-get min-expertise-threshold)) ERR-INSUFFICIENT-EXPERTISE)
    (asserts! (>= (get expertise-level target-expertise) (var-get min-expertise-threshold)) ERR-INSUFFICIENT-EXPERTISE)

    (let (
      (strength (calculate-connection-strength
                  (get expertise-level source-expertise)
                  (get expertise-level target-expertise)
                  u0))
    )
      (map-set cross-domain-connections
        { connection-id: connection-id }
        {
          creator: tx-sender,
          source-domain: source-domain,
          target-domain: target-domain,
          connection-type: connection-type,
          strength-score: strength,
          validation-count: u0,
          insight-description: insight-description,
          practical-applications: practical-applications,
          created-at: block-height,
          verified: false
        }
      )

      (update-thinking-patterns tx-sender connection-type)
      (var-set connection-counter connection-id)

      (ok connection-id)
    )
  )
)

(define-public (validate-cross-domain-connection (connection-id uint) (validation-score uint))
  (let (
    (connection (unwrap! (map-get? cross-domain-connections { connection-id: connection-id }) ERR-CONNECTION-NOT-FOUND))
    (validator-source-expertise (map-get? domain-expertise { user: tx-sender, domain: (get source-domain connection) }))
    (validator-target-expertise (map-get? domain-expertise { user: tx-sender, domain: (get target-domain connection) }))
  )
    (asserts! (not (is-eq tx-sender (get creator connection))) ERR-NOT-AUTHORIZED)
    (asserts! (<= validation-score u100) ERR-INVALID-INPUT)
    (asserts! (or (is-some validator-source-expertise) (is-some validator-target-expertise)) ERR-INSUFFICIENT-EXPERTISE)

    (let (
      (new-validation-count (+ (get validation-count connection) u1))
      (new-strength (calculate-connection-strength
                      u75 ;; Assume reasonable expertise for validation
                      u75
                      new-validation-count))
      (should-verify (and (>= new-validation-count u3) (>= validation-score u70)))
    )
      (map-set cross-domain-connections
        { connection-id: connection-id }
        (merge connection {
          validation-count: new-validation-count,
          strength-score: new-strength,
          verified: should-verify
        })
      )

      (ok should-verify)
    )
  )
)

(define-public (create-interdisciplinary-insight (primary-domain (string-ascii 50)) (secondary-domains (list 5 (string-ascii 50)))
                                                 (insight-title (string-ascii 150)) (insight-content (string-ascii 1000))
                                                 (novelty-score uint) (impact-potential uint))
  (let (
    (insight-id (+ (var-get insight-counter) u1))
    (primary-expertise (unwrap! (map-get? domain-expertise { user: tx-sender, domain: primary-domain }) ERR-INSUFFICIENT-EXPERTISE))
  )
    (asserts! (> (len insight-title) u0) ERR-INVALID-INPUT)
    (asserts! (> (len insight-content) u0) ERR-INVALID-INPUT)
    (asserts! (<= novelty-score u100) ERR-INVALID-INPUT)
    (asserts! (<= impact-potential u100) ERR-INVALID-INPUT)
    (asserts! (>= (get expertise-level primary-expertise) u60) ERR-INSUFFICIENT-EXPERTISE)

    (map-set interdisciplinary-insights
      { insight-id: insight-id }
      {
        creator: tx-sender,
        primary-domain: primary-domain,
        secondary-domains: secondary-domains,
        insight-title: insight-title,
        insight-content: insight-content,
        novelty-score: novelty-score,
        impact-potential: impact-potential,
        peer-reviews: u0,
        implementation-examples: u0,
        timestamp: block-height,
        validated: false
      }
    )

    (var-set insight-counter insight-id)
    (ok insight-id)
  )
)

(define-public (build-domain-bridge (connected-domains (list 10 (string-ascii 50))) (bridge-methodology (string-ascii 200)))
  (let (
    (bridge-id (+ (var-get bridge-counter) u1))
  )
    (asserts! (> (len connected-domains) u1) ERR-INVALID-INPUT)
    (asserts! (< (len connected-domains) u11) ERR-INVALID-INPUT)
    (asserts! (> (len bridge-methodology) u0) ERR-INVALID-INPUT)

    (map-set domain-bridges
      { bridge-id: bridge-id }
      {
        bridge-builder: tx-sender,
        connected-domains: connected-domains,
        bridge-methodology: bridge-methodology,
        success-metrics: (list u0 u0 u0 u0 u0),
        applications-developed: u0,
        collaboration-count: u0,
        innovation-score: u0,
        sustainability-rating: u50,
        created-at: block-height,
        active: true
      }
    )

    (var-set bridge-counter bridge-id)
    (ok bridge-id)
  )
)

(define-public (peer-review-insight (insight-id uint) (review-score uint) (implementation-feasibility uint))
  (let (
    (insight (unwrap! (map-get? interdisciplinary-insights { insight-id: insight-id }) ERR-INSIGHT-NOT-FOUND))
  )
    (asserts! (not (is-eq tx-sender (get creator insight))) ERR-NOT-AUTHORIZED)
    (asserts! (<= review-score u100) ERR-INVALID-INPUT)
    (asserts! (<= implementation-feasibility u100) ERR-INVALID-INPUT)

    (let (
      (new-review-count (+ (get peer-reviews insight) u1))
      (should-validate (and (>= new-review-count u3) (>= review-score u75)))
    )
      (map-set interdisciplinary-insights
        { insight-id: insight-id }
        (merge insight {
          peer-reviews: new-review-count,
          validated: should-validate
        })
      )

      (ok should-validate)
    )
  )
)

(define-public (update-collaboration-effectiveness (effectiveness-score uint))
  (let (
    (current-patterns (default-to
      { pattern-recognition-score: u0, analogical-thinking-level: u0, synthesis-capability: u0,
        creative-connections: u0, domain-fluidity: u0, innovation-index: u0,
        collaboration-effectiveness: u0, last-assessment: u0 }
      (map-get? thinking-patterns { user: tx-sender })
    ))
  )
    (asserts! (<= effectiveness-score u100) ERR-INVALID-INPUT)

    (map-set thinking-patterns
      { user: tx-sender }
      (merge current-patterns {
        collaboration-effectiveness: effectiveness-score,
        last-assessment: block-height
      })
    )

    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-domain-expertise (user principal) (domain (string-ascii 50)))
  (map-get? domain-expertise { user: user, domain: domain })
)

(define-read-only (get-cross-domain-connection (connection-id uint))
  (map-get? cross-domain-connections { connection-id: connection-id })
)

(define-read-only (get-interdisciplinary-insight (insight-id uint))
  (map-get? interdisciplinary-insights { insight-id: insight-id })
)

(define-read-only (get-domain-bridge (bridge-id uint))
  (map-get? domain-bridges { bridge-id: bridge-id })
)

(define-read-only (get-thinking-patterns (user principal))
  (map-get? thinking-patterns { user: user })
)

(define-read-only (get-connection-counter)
  (var-get connection-counter)
)

(define-read-only (get-insight-counter)
  (var-get insight-counter)
)

(define-read-only (calculate-interdisciplinary-score (user principal))
  (match (map-get? thinking-patterns { user: user })
    patterns (/ (+ (get pattern-recognition-score patterns)
                   (get analogical-thinking-level patterns)
                   (get synthesis-capability patterns)
                   (get creative-connections patterns)
                   (get domain-fluidity patterns)) u5)
    u0
  )
)

(define-read-only (get-min-expertise-threshold)
  (var-get min-expertise-threshold)
)
