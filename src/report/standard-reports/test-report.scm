(define-module (gnucash report test-report))
(use-modules (gnucash main)) ;; FIXME: delete after we finish modularizing.
(use-modules (ice-9 slib))
(use-modules (gnucash gnc-module))
(require 'printf)
(gnc:module-load "gnucash/report/report-system" 0)
(gnc:module-load "gnucash/gnome-utils" 0) ;for gnc-build-url
(define reportname (N_ "Cash Flow"))
(define optname-from-date (N_ "From"))
(define optname-to-date (N_ "To"))

;; options generator
(define (cash-flow-options-generator)
  (let ((options (gnc:new-options)))
    ;; date interval
    (gnc:options-add-date-interval!
     options gnc:pagename-general 
     optname-from-date optname-to-date "a")
    options))

;; cash-flow-renderer
(define (cash-flow-renderer report-obj)
  (define (get-option pagename optname)
    (gnc:option-value
     (gnc:lookup-option 
      (gnc:report-options report-obj) pagename optname)))
  (let* ((doc (gnc:make-html-document)))
    (display "gnc:timepair-start-day-time:\n")
    (display (gnc:timepair-start-day-time 
                   (gnc:date-option-absolute-time
                    (get-option gnc:pagename-general
                                optname-from-date))))
    (display "\n---\n")
    (display "gnc:date-option-absolute-time:\n")
    (display (gnc:date-option-absolute-time
                    (get-option gnc:pagename-general
                                optname-from-date)))
    (display "\n---\n")
    (display "get-option:\n")
    (display (get-option gnc:pagename-general
                                optname-from-date))
    (display "\n---==---\n")
    doc))

(gnc:define-report 
 'version 1
 'name reportname
 'report-guid "25594927d56d45e6a7398b3d83be2ac9"
 'menu-path (list gnc:menuname-income-expense)
 'options-generator cash-flow-options-generator
 'renderer cash-flow-renderer)
