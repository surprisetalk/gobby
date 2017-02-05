#lang racket

(require net/http-client)
(require html-parsing)

(let-values (((a b c) (http-sendrecv "arademaker.github.io"
                                     "/about.html")))
  (html->xexp c))
