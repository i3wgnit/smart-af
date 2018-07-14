#lang racket
(require "evmasm.rkt")
(define prog
  `(;; ===
    ;; Constants
    ;; ===

    (def codeLength 0)
    (def codePointer 32)

    (def tapeLength 64)
    (def tapePointer 96)

    (def outLength 128)
    (def codeP_off 160)

    (def output_off (+ codeP_off (+ (mload codeLength) (mload tapeLength))))

    ;; ===
    ;; Constructor
    ;; ===

    ;; ===
    ;; Initialization
    ;; ===

    ;; ===
    ;; Main loop
    ;; ===
    (dest mainLoop:start)

    ;; ===
    ;; Check if character is valid
    ;; ===
    (mload codePointer)
    (mstore codePointer (add 1 (dup1)))
    (and #xff (mload (add codeP_off)))

    (jumpi label:deploy (iszero (dup1))) ;; should check with code length instead

    (jumpi label:+ (eq ,(char->integer #\+) (dup1)))
    (jumpi label:- (eq ,(char->integer #\-) (dup1)))
    (jumpi label:> (eq ,(char->integer #\>) (dup1)))
    (jumpi label:< (eq ,(char->integer #\<) (dup1)))
    (jumpi label:A (eq ,(char->integer #\[) (dup1)))
    (jumpi label:B (eq ,(char->integer #\]) (dup1)))
    (jumpi label:. (eq ,(char->integer #\.)))

    (jump mainLoop:start)

    ;; ===
    ;; BF Operators
    ;; ===

    (dest label:+)
    (pop)
    (mload tapePointer)
    (add (and #xff (mload (dup2))) 1)
    (mstore8 (swap1))
    (jump mainLoop:start)

    (dest label:-)
    (pop)
    (mload tapePointer)
    (sub (and #xff (mload (dup2))) 1)
    (mstore8 (swap1))
    (jump mainLoop:start)

    (dest label:>)
    (pop)
    (add (mload tapePointer) 1)
    (mstore tapePointer)
    (jump mainLoop:start)

    (dest label:<)
    (pop)
    (sub (mload tapePointer) 1)
    (mstore tapePointer)
    (jump mainLoop:start)

    (dest label:A)
    (pop)
    (mload codePointer)
    (jump mainLoop:start)

    (dest label:B)
    (pop)
    (jumpi B:loop (mload tapePointer))
    (pop)
    (jump mainLoop:start)

    (dest B:loop)
    (mstore codePointer)
    (jump mainLoop:start)

    (dest label:.)
    (and #xff (mload (mload tapePointer)))
    (mload outLength)
    (mstore outLength (add 1 (dup1)))
    (mstore8 (add output_off))
    (jump mainLoop:start)

    (dest label:deploy)
    (return output_off (mload outLength))
    ))

(evm-assemble prog)
