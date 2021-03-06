;; -*- Scheme -*-
;;
;; $Id$
;;

;; Returns the depth of the auto-generated TOC (table of
;; contents) that should be made at the nd-level
(define (toc-depth nd)
  (if (string=? (gi nd) "book")
      2 ; the depth of the top-level TOC
      1 ; the depth of all other TOCs
      ))

;; Make function definitions bold
(element (funcdef function) 
  ($bold-seq$
   (make sequence
     (process-children)
     )
   )
  )




;; Linking types to the correct place
(element type
  (let* 
    ((orig-name (data (current-node)))
      (type-name (cond 
        ((equal-ci? orig-name "double") "float")
        ((equal-ci? orig-name "int")   "integer")
        (else orig-name))
      )
      (linkend (string-append "language.types." type-name))
      (target (element-with-id linkend))
    )
    (cond ((node-list-empty? target)
      (make sequence (process-children) )
      )
      (else 
        (make element gi: "A"
          attributes: (list (list "HREF" (href-to target)))
          ( $bold-seq$(make sequence (process-children) ) )
        )
      )
    )
  )
)

;; Linking of function tags
(element function
  (let* ((function-name (data (current-node)))
     (linkend 
      (string-append
       "function." 
       (string-replace
        (string-replace function-name "_" "-")
        "::" ".")))
     (target (element-with-id linkend))
     (parent-gi (gi (parent))))
    (cond
     ;; function names should be plain in FUNCDEF
     ((equal? parent-gi "funcdef")
      (process-children))
     
     ;; If a valid ID for the target function is not found, or if the
     ;; FUNCTION tag is within the definition of the same function,
     ;; make it bold, add (), but don't make a link
     ((or (node-list-empty? target)
      (equal? (case-fold-down
           (data (node-list-first
              (select-elements
               (node-list-first
                (children
                 (select-elements
                  (children
                   (ancestor-member (parent) (list "refentry")))
                  "refnamediv")))
               "refname"))))
          function-name))
      ($bold-seq$
       (make sequence
     (process-children)
     (literal "()"))))
     
     ;; Else make a link to the function and add ()
     (else
      (make element gi: "A"
        attributes: (list
             (list "HREF" (href-to target)))
        ($bold-seq$
         (make sequence
           (process-children)
           (literal
        )
           (literal "()"))))))))


;; Link for classnames
(element classname
  (let* ((class-name (data (current-node)))
     (linkend 
      (string-append
       "class." 
        (string-replace
         (case-fold-down class-name) "_" "-")))
     (target (element-with-id linkend))
     (parent-gi (gi (parent))))
    (cond
     ;; Function names should be plain in SYNOPSIS
     ((equal? parent-gi "synopsis")
      (process-children))
     
     ;; If a valid ID for the target class is not found, or if the
     ;; CLASSNAME tag is within the definition of the same class,
     ;; make it bold, but don't make a link
     ((or (node-list-empty? target)
      (equal? (case-fold-down
           (data (node-list-first
              (select-elements
               (node-list-first
                (children
                 (select-elements
                  (children
                   (ancestor-member (parent) (list "refentry")))
                  "refnamediv")))
               "refname"))))
          class-name))
      ($bold-seq$
       (process-children)))
     
     ;; Else make a link to the class
     (else
      (make element gi: "A"
        attributes: (list
             (list "HREF" (href-to target)))
        ($bold-seq$
         (process-children)))))))


;; Linking to constants
(element constant
  (let* ((constant-name (data (current-node)))
     (linkend 
      (string-append "constant." 
             (case-fold-down
              (string-replace constant-name "_" "-"))))
     (target (element-with-id linkend))
     (parent-gi (gi (parent))))
    (cond
;     ;; constant names should be plain in FUNCDEF
;     ((equal? parent-gi "funcdef")
;      (process-children))
     
     ;; If a valid ID for the target constant is not found, or if the
     ;; CONSTANT tag is within the definition of the same constant,
     ;; make it bold, but don't make a link
     ((or (node-list-empty? target)
      (equal? (case-fold-down
           (data (node-list-first
              (select-elements
               (node-list-first
                (children
                 (select-elements
                  (children
                   (ancestor-member (parent) (list "refentry")))
                  "refnamediv")))
               "refname"))))
          constant-name))
      ($bold-mono-seq$
       (process-children)))
     
     ;; Else make a link to the constant
     (else
      (make element gi: "A"
        attributes: (list
             (list "HREF" (href-to target)))
        ($bold-mono-seq$
         (process-children)))))))


;; Dispaly of examples
(element example
  (make sequence
    (make element gi: "TABLE"
      attributes: (list
               (list "WIDTH" "100%")
               (list "BORDER" "0")
               (list "CELLPADDING" "0")
               (list "CELLSPACING" "0")
               (list "CLASS" "EXAMPLE"))
      (make element gi: "TR"
        (make element gi: "TD"
              ($formal-object$))))))


;; Prosessing tasks for the frontpage
(mode book-titlepage-recto-mode
  (element authorgroup
    (process-children))
    
  (element author
    (let ((author-name  (author-string))
          (author-affil (select-elements (children (current-node)) 
                                         (normalize "affiliation"))))
      (make sequence      
        (make element gi: "DIV"
              attributes: (list (list "CLASS" (gi)))
              (literal author-name))
        (process-node-list author-affil))))
    )


;; Put version info where the refname part in the refnamediv is
(element (refnamediv refname)
  (make sequence
    (make element gi: "P"
      (literal "    (")
      (version-info (current-node))
      (literal ")")
      )
    (process-children)
    )
  )

;; Display of question tags, link targets
(element question
  (let* ((chlist   (children (current-node)))
         (firstch  (node-list-first chlist))
         (restch   (node-list-rest chlist)))
    (make element gi: "B"
    (make element gi: "DIV"
          attributes: (list (list "CLASS" (gi)))
          (make element gi: "P"
                (make element gi: "A"
                      attributes: (list (list "NAME" (element-id)))
                      (empty-sosofo))
                (make element gi: "B"
                      (literal (question-answer-label (current-node)) " "))
                (process-node-list (children firstch)))
          (process-node-list restch))))   )          

;; Adding class HTML parameter to examples
;; having a role parameter, to make PHP exaxmples
;; distinguisable from other ones in the manual
(define ($verbatim-display$ indent line-numbers?)
  (let (
(content (make element gi: "PRE"
       attributes: (list
    (list "CLASS" (if (attribute-string (normalize "role"))
      (attribute-string (normalize "role"))
      (gi))))
       (if (or indent line-numbers?)
   ($verbatim-line-by-line$ indent line-numbers?)
   (process-children)))))
    (if %shade-verbatim%
(make element gi: "TABLE"
      attributes: ($shade-verbatim-attr$)
      (make element gi: "TR"
    (make element gi: "TD"
  content)))
(make sequence
  (para-check)
  content
  (para-check 'restart)))))




;; vim: ts=2 sw=2 et
