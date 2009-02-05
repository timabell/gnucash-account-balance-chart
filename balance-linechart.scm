;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; balance-linechart.scm: A line chart report of account balances.
;; Based on hello world, price-scatter and average-balance.
;;
;; By Tim Abell <tim.abell@timwise.co.uk>
;;
;; This program is free software; you can redistribute it and/or    
;; modify it under the terms of the GNU General Public License as   
;; published by the Free Software Foundation; either version 2 of   
;; the License, or (at your option) any later version.              
;;                                                                  
;; This program is distributed in the hope that it will be useful,  
;; but WITHOUT ANY WARRANTY; without even the implied warranty of   
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    
;; GNU General Public License for more details.                     
;;                                                                  
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, contact:
;;
;; Free Software Foundation           Voice:  +1-617-542-5942
;; 51 Franklin Street, Fifth Floor    Fax:    +1-617-542-2652
;; Boston, MA  02110-1301,  USA       gnu@gnu.org
;;
;; TODO: copy loading input data from net-barchart.scm
;; TODO: copy graph display from price-scatter.scm
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-module (gnucash report balance-linechart))
(use-modules (gnucash main)) ;; FIXME: delete after we finish modularizing.
(use-modules (srfi srfi-1)) ;;needed for printf I think
(use-modules (ice-9 slib)) ;;needed for printf I think
(use-modules (gnucash gnc-module))

(require 'printf)

(debug-enable 'debug)
(debug-enable 'backtrace)

(gnc:module-load "gnucash/report/report-system" 0)
(gnc:module-load "gnucash/gnome-utils" 0) ;for gnc-build-url

;; This function will generate a set of options that GnuCash
;; will use to display a dialog where the user can select
;; values for your report's parameters.

(define optname-display-depth (N_ "Account Display Depth"))
(define optname-show-subaccounts (N_ "Always show sub-accounts"))
(define optname-accounts (N_ "Account"))

(define optname-marker (N_ "Marker"))
(define optname-markercolor (N_ "Marker Color"))
(define optname-plot-width (N_ "Plot Width"))
(define optname-plot-height (N_ "Plot Height"))

(define optname-from-date (N_ "From"))
(define optname-to-date (N_ "To"))
(define optname-stepsize (N_ "Step Size"))

(define (options-generator)    
  (let* ((options (gnc:new-options)) 
         ;; This is just a helper function for making options.
         ;; See gnucash/src/scm/options.scm for details.
         (add-option 
          (lambda (new-option)
            (gnc:register-option options new-option))))

    ;; accounts to work on
    (gnc:options-add-account-selection! 
     options gnc:pagename-accounts
     optname-display-depth optname-show-subaccounts
     optname-accounts "a" 2
     (lambda ()
       (gnc:filter-accountlist-type 
        (list ACCT-TYPE-BANK ACCT-TYPE-CASH ACCT-TYPE-ASSET
              ACCT-TYPE-STOCK ACCT-TYPE-MUTUAL)
        (gnc-account-get-descendants-sorted (gnc-get-current-root-account))))
     #f)

    (gnc:options-add-date-interval!
     options gnc:pagename-general
     optname-from-date optname-to-date "a")

    (gnc:options-add-interval-choice!
     options gnc:pagename-general optname-stepsize "b" 'MonthDelta)

    (add-option
     (gnc:make-color-option
      gnc:pagename-display (N_ "Background Color")
      "f" (N_ "This is a color option")
      (list #xf6 #xff #xdb 0)
      255
      #f))
    (add-option
     (gnc:make-color-option
      gnc:pagename-display (N_ "Text Color")
      "f" (N_ "This is a color option")
      (list #x00 #x00 #x00 0)
      255
      #f))

    (gnc:options-add-plot-size! 
     options gnc:pagename-display 
     optname-plot-width optname-plot-height "c" 500 400)

    (gnc:options-add-marker-choice!
     options gnc:pagename-display 
     optname-marker "a" 'filledsquare)

    (add-option
     (gnc:make-color-option
      gnc:pagename-display optname-markercolor
      "b"
      (N_ "Color of the marker")
      (list #xb2 #x22 #x22 0)
       255 #f))

    (gnc:options-set-default-section options gnc:pagename-general)
    options))

;; This is the rendering function. It accepts a database of options
;; and generates an object of type <html-document>.  See the file
;; report-html.txt for documentation; the file report-html.scm
;; includes all the relevant Scheme code. The option database passed
;; to the function is one created by the options-generator function
;; defined above.
(define (balance-linechart-renderer report-obj)
  ;; These are some helper functions for looking up option values.
  (define (get-option section name)
		 (gnc:lookup-option (gnc:report-options report-obj) section name)
	)

  
  (define (op-value section name)
    (gnc:option-value (get-option section name)))

;;  (gnc:report-starting reportname) ;;TODO what's this for? (also stopping)
;;(gnc:report-percent-done 1) ;;TODO progress also available
  
  ;; The first thing we do is make local variables for all the specific
  ;; options in the set of options given to the function. This set will
  ;; be generated by the options generator above.
  (let* ((bg-color-op  (get-option   gnc:pagename-display "Background Color"))
        (txt-color-op (get-option   gnc:pagename-display "Text Color"))
        (report-title (get-option gnc:pagename-general 
                                   gnc:optname-reportname))
         (height (get-option gnc:pagename-display optname-plot-height))
         (width (get-option gnc:pagename-display optname-plot-width))
         (marker (get-option gnc:pagename-display optname-marker))
         (mcolor 
          (gnc:color-option->hex-string
           (gnc:lookup-option (gnc:report-options report-obj)
                              gnc:pagename-display optname-markercolor)))

	(from-date-tp (gnc:timepair-start-day-time 
		(gnc:date-option-absolute-time
			(gnc:option-value (get-option gnc:pagename-general
				optname-from-date))))) ;;fails
	(to-date-tp (gnc:timepair-end-day-time 
		(gnc:date-option-absolute-time
		(gnc:option-value (get-option gnc:pagename-general
				optname-to-date))))) ;;fails
       (interval (get-option gnc:pagename-general optname-stepsize))

        ;; document will be the HTML document that we return.
        (document (gnc:make-html-document))
         (chart (gnc:make-html-scatter)))

 (let 
	((time-string (strftime "%X" (localtime (current-time)))))
	
	;; Here's where we fill the report document with content.
	(gnc:html-document-set-style!
	document "body" 
	'attribute (list "bgcolor" (gnc:color-option->html bg-color-op))
	'font-color (gnc:color-option->html txt-color-op))
	
	;; the title of the report
	(gnc:html-document-set-title! document (_ "Balance line chart"))
	
	(gnc:html-scatter-set-title! chart report-title)
	(gnc:html-scatter-set-width! chart width)
	(gnc:html-scatter-set-height! chart height)
	(gnc:html-scatter-set-marker! chart 
					(case marker
					((circle) "circle")
					((cross) "cross")
					((square) "square")
					((asterisk) "asterisk")
					((filledcircle) "filled circle")
					((filledsquare) "filled square")))
	(gnc:html-scatter-set-markercolor! chart mcolor)

  (gnc:html-document-add-object! document
		(gnc:make-html-text
		(gnc:html-markup-p (sprintf #f
			(_ "%s to %s")
			(gnc-print-date from-date-tp)
			(gnc-print-date to-date-tp)))))

	(gnc:html-scatter-set-subtitle!
	  chart (sprintf #f
			(_ "%s to %s")
			(gnc-print-date from-date-tp)
			(gnc-print-date to-date-tp)))
	
	(gnc:html-scatter-set-y-axis-label! chart "£") ;;TODO unharcode currency label

 )

      document))

;; Here we define the actual report
(gnc:define-report
 'version 1
 'name (N_ "Balance line chart")
 'report-guid "6f78b99926754df1ba01019831079fe8"
 'menu-tip (N_ "Plot account balance over time.")
 'menu-path (list gnc:menuname-asset-liability)
 'options-generator options-generator
 'renderer balance-linechart-renderer)
