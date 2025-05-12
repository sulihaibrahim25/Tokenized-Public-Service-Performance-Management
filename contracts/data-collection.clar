;; Data Collection Contract
;; Records service delivery statistics for performance metrics

(define-data-var contract-owner principal tx-sender)

;; Data map to store performance data points
(define-map performance-data uint
  {
    metric-id: uint,
    value: uint,
    collection-date: uint,
    collector: principal,
    notes: (string-utf8 200)
  }
)

;; Counter for data point IDs
(define-data-var next-data-id uint u1)

;; Public function to record a new data point
(define-public (record-data-point
                (metric-id uint)
                (value uint)
                (notes (string-utf8 200)))
  (begin
    ;; Simplified: In a real deployment, you would check if the metric exists and is owned by the caller
    ;; For simplicity, we're just recording the collector principal

    (let ((data-id (var-get next-data-id)))
      (map-set performance-data
        data-id
        {
          metric-id: metric-id,
          value: value,
          collection-date: block-height,
          collector: tx-sender,
          notes: notes
        }
      )
      (var-set next-data-id (+ data-id u1))
      (ok data-id)
    )
  )
)

;; Read-only function to get data point details
(define-read-only (get-data-point (data-id uint))
  (map-get? performance-data data-id)
)

;; Read-only function to get total number of data points
(define-read-only (get-data-count)
  (var-get next-data-id)
)

;; Initialize contract
(begin
  (var-set contract-owner tx-sender)
  (var-set next-data-id u1)
)
