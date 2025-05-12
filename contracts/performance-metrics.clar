;; Performance Metric Contract
;; Establishes measurement standards for public services

(define-data-var contract-owner principal tx-sender)

;; Data map to store performance metrics
(define-map performance-metrics uint
  {
    service-id: uint,
    metric-name: (string-utf8 100),
    metric-description: (string-utf8 500),
    target-value: uint,
    unit: (string-utf8 20),
    creation-date: uint,
    agency-principal: principal
  }
)

;; Counter for metric IDs
(define-data-var next-metric-id uint u1)

;; Public function to create a new performance metric
(define-public (create-metric
                (service-id uint)
                (metric-name (string-utf8 100))
                (metric-description (string-utf8 500))
                (target-value uint)
                (unit (string-utf8 20)))
  (begin
    ;; Simplified: In a real deployment, you would check if the service exists and is owned by the caller
    ;; For simplicity, we're just recording the agency principal

    (let ((metric-id (var-get next-metric-id)))
      (map-set performance-metrics
        metric-id
        {
          service-id: service-id,
          metric-name: metric-name,
          metric-description: metric-description,
          target-value: target-value,
          unit: unit,
          creation-date: block-height,
          agency-principal: tx-sender
        }
      )
      (var-set next-metric-id (+ metric-id u1))
      (ok metric-id)
    )
  )
)

;; Public function to update a metric's target value
(define-public (update-metric-target (metric-id uint) (new-target-value uint))
  (let ((metric (map-get? performance-metrics metric-id)))
    (begin
      (asserts! (is-some metric) (err u3)) ;; Metric must exist
      (asserts! (is-eq (get agency-principal (unwrap-panic metric)) tx-sender) (err u5)) ;; Only the owning agency can update

      (map-set performance-metrics
        metric-id
        (merge (unwrap-panic metric) { target-value: new-target-value })
      )
      (ok true)
    )
  )
)

;; Read-only function to get metric details
(define-read-only (get-metric-details (metric-id uint))
  (map-get? performance-metrics metric-id)
)

;; Read-only function to get total number of metrics
(define-read-only (get-metric-count)
  (var-get next-metric-id)
)

;; Initialize contract
(begin
  (var-set contract-owner tx-sender)
  (var-set next-metric-id u1)
)
