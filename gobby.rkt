#lang racket

(require net/http-client)
(require html-parsing)


;; CLI ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|

gobby <url> <destination>

|#

;;; TODO: command-line parsing


;; CRAWLER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; url-split : String -> Values (List String String)
(define (url-split url)
  (let ([paths (string-split url "/")])
    (values (first paths)
            (string-append "/"
                           (string-join
                            (rest paths)
                            "/")))))

;;; crawl : String -> XExp
;;  eg (crawl "arademaker.github.io/about.html")
(define (crawl url)
  (let*-values ([(host endpoint) (url-split url)]
                [(a b c) (http-sendrecv host endpoint)])
    (html->xexp c)))


;; GOBBY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; gobby : String -> TODO
(define (gobby src dest)
  (cond [(url-match? src "youtube.com")
         ;; TODO: without dest, we should use youtube-dl -o to pipe to stdout
         (system (string-append "youtube-dl "
                                src))]
        [#t (crawl src)]))
