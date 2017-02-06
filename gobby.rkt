#lang racket


;; IMPORTS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require racket/system)
(require net/http-client)
(require html-parsing)


;; I/O ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (stdin)  (current-input-port) )
(define (stdout) (current-output-port))


;; CLI ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; gobby-cli : () -> CommandLineApp
(define (gobby-cli)
  (define verbose-mode? #f)
  (define    file-mode? #f)
  (command-line
   #:program "gobby"
   #:once-each
   [("-v" "--verbose") "verbose mode"
                       (set! verbose-mode? #t)]
   [("-f" "--file")    "save a file in the current dir"
                       (set! file-mode? #t)]
   #:args srcs
   ;; TODO: raise argument error if no args
   (for ([src srcs])
     (gobby src #:file-mode? file-mode?))))


;; URL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; url-split : String -> Values (List String String)
(define (url-split url)
  (let-values ([(str protocol subdomain domain uri)
                (apply values
                       (regexp-match #rx"^(http://|https://)?([^/]+\\.)?([^/]+\\.[^/]+)(/.*)?$"
                                     url))])

    (values (if domain
                (string-append
                 (if subdomain subdomain "www.")
                 domain)
                "")
            (if uri uri ""))))

;;; url-match? : String -> String -> Bool
(define url-match? string-contains?)


;; CRAWL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#| TODO

youtube-dl sites
reddit
hn
imgur
discogs
pocket?
else try to grab text and title
 
|#

;;; crawl : String -> Pair String any
;;  eg (crawl "arademaker.github.io/about.html")
(define (crawl url)
  (let*-values ([(host endpoint) (url-split url)]
                [(a b c) (http-sendrecv host endpoint #:ssl? #t)]
                [(page) (html->xexp c)])
    (cond [(url-match? url "reddit.com")           (cons "reddit_todo.txt" page)]
          [(url-match? url "news.ycombinator.com") (cons "hn_todo.txt"     page)]
          [#t (raise-result-error 'crawl "string?" url)])))


;; GOBBY ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; gobby: String -> String -> ()
(define (gobby src #:file-mode? [file-mode? #f])
  (cond [(not (string? src)) (raise-type-error 'gobby "string?" src)]
        [(url-match? src "youtube.com")
         (system (string-join (list "youtube-dl"
                                    (if file-mode? "" "-o -")
                                    src)))]
        [#t (let ([crawl-result (crawl src)])
              (if file-mode?
                  (display-to-file (cdr crawl-result)
                                   (car crawl-result))
                  (display (cdr crawl-result) (stdout))))]))


;; MAIN ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(gobby-cli)
  
