(define-module (gnucash report balance-linechart))
(use-modules (gnucash main)) ;; FIXME: delete after we finish modularizing.
(use-modules (ice-9 slib)) ;;needed for printf I think
;;(use-modules (srfi srfi-1)) ;;needed for printf I think
(use-modules (gnucash gnc-module))

(require 'printf)

(gnc:module-load "gnucash/report/report-system" 0)
(gnc:module-load "gnucash/gnome-utils" 0) ;for gnc-build-url

(define optname-from-date (N_ "From"))
(define optname-to-date (N_ "To"))


(define (options-generator)
  (let ((options (gnc:new-options)))

    (gnc:options-add-date-interval!
     options gnc:pagename-general
     optname-from-date optname-to-date "a")

    options))


(define (balance-linechart-renderer report-obj)
  (define (get-option section name)
  
    (gnc:lookup-option 
    (gnc:report-options report-obj) section name))

  (let* (

	(testvalue (get-option gnc:pagename-general optname-to-date)) ;;is ok
	(testvalue3 (gnc:date-option-absolute-time (gnc:option-value testvalue)));;??
;;	(testvalue2 (gnc:date-option-absolute-time (testvalue)));;fails
;;	(testvalue (gnc:date-option-absolute-time(get-option gnc:pagename-general optname-to-date))) ;;fails

        (document (gnc:make-html-document))
       )

      document))

(gnc:define-report
 'version 1
 'name (N_ "Balance line chart")
 'report-guid "6f78b99926754df1ba01019831079fe8"
 'menu-tip (N_ "Plot account balance over time.")
 'menu-path (list gnc:menuname-asset-liability)
 'options-generator options-generator
 'renderer balance-linechart-renderer)
