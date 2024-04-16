
;; title: evently
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
;;
(define-constant contract-owner tx-sender)
(define-constant ERR_UNKNOWN_EVENT (err 404))
(define-constant ERR_UNAUTHORISED (err 403))
(define-constant ERR_EVENT_EXPIRED (err 410))
(define-constant ERR_MAX_VALUE (err 413))
(define-constant ERR_EMPTY_VALUE (err 410))
(define-constant ERR_ALREADY_REGISTER (err 409))

;; data vars
;;

;; data maps
;;
(define-map tickets
  { ticket-id: (string-ascii 40) }
  { event-id: (string-ascii 40), owner: principal }
)

(define-map events
  { event-id: (string-ascii 40) }
  {
    owner: principal,
    pricePerTicket: uint,
    ticketLimit: uint,
    ticketsSold: uint,
    expiry: uint,
  }
)

(define-map tickets-by-event
  { event-id: (string-ascii 40) }
  { tickets: (list 100 { ticket-id: (string-ascii 40), owner: principal }) })

(define-map tickets-by-owner
  { owner: principal }
  { tickets: (list 100 { event-id: (string-ascii 40), ticket-id: principal }) })

;; public functions
;;
(define-public (add-event (event-id (string-ascii 40)) (price-per-ticket uint) (ticket-limit uint) (expiry uint))
  (let ((existing-event (map-get? events { event-id: event-id })))
    (match existing-event
      event (err ERR_ALREADY_REGISTER)
      (begin
        (map-set events
                 { event-id: event-id }
                 { owner: tx-sender, pricePerTicket: price-per-ticket, ticketLimit: ticket-limit, ticketsSold: u0, expiry: expiry })
        (ok true))))
)

(define-public (update-event (event-id (string-ascii 40)) (owner principal) (price-per-ticket uint) (ticket-limit uint) (expiry uint))
    (let ((event-details (unwrap! (map-get? events { event-id: event-id }) (err ERR_UNKNOWN_EVENT))))
        (begin
            (asserts! ((or (is-eq tx-sender (get owner event-details) (is-eq tx-sender contract-owner))) (err ERR_UNAUTHORISED))
            (asserts! (>= ticket-limit (get ticketsSold event-details)) (err ERR_MAX_VALUE))
            (map-set events
                    { event-id: event-id }
                    { owner: owner, pricePerTicket: price-per-ticket, ticketLimit: ticket-limit, ticketsSold: (get ticketsSold event-details), expiry: expiry })
            (ok true)))
)


(define-public (buy-ticket (event-id (string-ascii 40)) (ticket-id (string-ascii 40)))
    (begin
        (asserts! (not (is-eq ticket-id "")) (err ERR_EMPTY_VALUE))
        (asserts! (not (is-eq event-id "")) (err ERR_EMPTY_VALUE))
        (let ((event-details (unwrap! (map-get? events { event-id: event-id }) (err ERR_UNKNOWN_EVENT)))
            (existing-ticket (map-get? tickets { ticket-id: ticket-id })))
            (match existing-ticket
                event (err ERR_ALREADY_REGISTER)
            (let ((tickets-sold (get ticketsSold event-details))
                (ticket-limit (get ticketLimit event-details))
                (price-per-ticket (get pricePerTicket event-details))
                (event-owner (get owner event-details))
                (expiry (get expiry event-details)))
                (asserts! (< tickets-sold ticket-limit) (err ERR_MAX_VALUE))
                ;;(asserts! (< block-height expiry) (err ERR_EVENT_EXPIRED))
                ;;(if (> price-per-ticket u0)
                  ;;  (begin
                    ;;    (stx-transfer? price-per-ticket tx-sender event-owner)))
                (map-set tickets
                    { ticket-id: ticket-id }
                    { event-id: event-id, owner: tx-sender })
                (map-set events
                    { event-id: event-id }
                    { owner: event-owner,
                    pricePerTicket: price-per-ticket,
                    ticketLimit: ticket-limit,
                    ticketsSold: (+ u1 tickets-sold),
                    expiry: expiry })
                (let ((owner-tickets (unwrap-panic (default-to (list) (get ticket-ids (map-get? tickets-by-owner { owner: tx-sender }))))))
                        (asserts! (< (len owner-tickets) (var-get max-tickets)) (err "Ticket limit per owner exceeded"))
                        (map-set tickets-by-owner
                            { owner: tx-sender }
                            { ticket-ids: (as-max-len? (append owner-tickets (list ticket-id)) (var-get max-tickets)) }))
                (ok true)
            ))
        )
    )
)


;; read only functions
;;
(define-read-only (get-event (event-id (string-ascii 40)))
  (map-get? events { event-id: event-id }))

(define-read-only (get-ticket (ticket-id (string-ascii 40)))
  (map-get? tickets { ticket-id: ticket-id }))

(define-read-only (get-tickets-by-owner (owner principal))
    (let ((tickets-owner (map-get? tickets-by-owner { owner: owner })))
        (match tickets-owner
            ticket-data (ok (get ticket-ids ticket-data))
            (ok (list))
        )))

;; private functions
;;

;; (contract-call? .evently add-event "event123" 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u250 u100 u20250101)
;; (contract-call? .evently buy-ticket "event123" "ticket123")
