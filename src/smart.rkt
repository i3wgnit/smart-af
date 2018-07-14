#lang racket
(require "evmasm.rkt")
(define prog
  '(;; ===
    ;; Constants
    ;; ===

    (def codePointer 0)
    (def tapePointer 32)
    (def outLength 64)

    (calldataload 0)
    (mstore tapePointer)
    ))

(evm-assemble prog)
