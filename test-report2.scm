(define-module (gnucash report test-report))
(use-modules (gnucash main)) ;; FIXME: delete after we finish modularizing.
(use-modules (gnucash gnc-module))
(debug-enable 'debug)
(debug-enable 'backtrace)
(gnc:module-load "gnucash/report/report-system" 0)

(define optname-from-date (N_ "Start Date"))
(define optname-to-date (N_ "End Date"))
(define (options-generator)    
  (let* ((options (gnc:new-options)) 
         (add-option 
          (lambda (new-option)
            (gnc:register-option options new-option))))

    (gnc:options-add-date-interval!
     options gnc:pagename-general
     optname-from-date optname-to-date "a")

    (gnc:options-set-default-section options gnc:pagename-general)
    options))

(define (balance-linechart-renderer report-obj)
  (define (get-option section name)
    (gnc:lookup-option (gnc:report-options report-obj) section name))
  (define (op-value section name)
    (gnc:option-value (get-option section name)))
  (let* (
         (testvalue (get-option gnc:pagename-general optname-to-date)) ;;is ok
;;	 (testvalue2 (gnc:date-option-absolute-time testvalue));;fails
;;objective:
;;                  (to-date-tp (gnc:timepair-end-day-time 
;;                      (gnc:date-option-absolute-time
;;                       (get-option gnc:pagename-general
;;                                   optname-to-date))))
         
         (document (gnc:make-html-document))
        )

	(gnc:html-document-set-title! document (_ "Test report"))
    (display "hello world\n")
    (testvalue2 (gnc:date-option-absolute-time testvalue));;fails
    (display "\n")
    (display testvalue)
    (display "\n")

      document))


(gnc:define-report
 'version 1
 'name (N_ "Test report")
 'report-guid "25594927d56d45e6a7398b3d83be2ac9"
 'menu-tip (N_ "fubar your brain.")
 'menu-path (list gnc:menuname-asset-liability)
 'options-generator options-generator
 'renderer balance-linechart-renderer)
