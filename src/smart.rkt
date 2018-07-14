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
    (def codeStart 160)
    (def codeP_off (- codeStart 31))

    (def output_off (add codeStart (add (mload codeLength) (mload tapeLength))))

    ;; ===
    ;; Constructor
    ;; ===

    ;; ===
    ;; Initialization
    ;; ===

    ;; Get the size of the current bytecode
    (codecopy tapeLength (dataSize bytecode) 32) ;; Tape length
    (codecopy codeLength (+ 64 (dataSize bytecode)) 32) ;; String length
    (codecopy codeStart (+ 96 (dataSize bytecode)) (mload codeLength))

    (mstore tapePointer (add codeP_off (mload codeLength)))

    ;; ===
    ;; Main loop
    ;; ===
    (dest mainLoop:start)

    ;; ===
    ;; Check if character is valid
    ;; ===
    (mload codePointer)
    (jumpi label:deploy (eq (mload codeLength) (dup1)))
    (mstore codePointer (add 1 (dup1)))
    (and #xff (mload (add codeP_off)))

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

    ;; Increment cell
    (dest label:+)
    (pop) ;; Pop original char off the stack
    (mload tapePointer)
    (add (and #xff (mload (dup2))) 1)
    (mstore8 (add 31 (swap1)))
    (jump mainLoop:start)

    ;; Decrement cell
    (dest label:-)
    (pop)
    (mload tapePointer)
    (sub (and #xff (mload (dup2))) 1)
    (mstore8 (add 31 (swap1)))
    (jump mainLoop:start)

    ;; Increment pointer
    (dest label:>)
    (pop)
    (add (mload tapePointer) 1)
    (mstore tapePointer)
    (jump mainLoop:start)

    ;; Decrement pointer
    (dest label:<)
    (pop)
    (sub (mload tapePointer) 1)
    (mstore tapePointer)
    (jump mainLoop:start)

    ;; Mark loop point
    (dest label:A)
    (pop)
    (mload codePointer)
    (jump mainLoop:start)

    ;; Check if loop
    (dest label:B)
    (pop)
    (jumpi B:loop (and #xff (mload (mload tapePointer))))
    (pop)
    (jump mainLoop:start)

    ;; Loop
    (dest B:loop)
    (mstore codePointer (dup1))
    (jump mainLoop:start)

    ;; Printing
    (dest label:.)
    (and #xff (mload (mload tapePointer)))
    (mload outLength)
    (mstore outLength (add 1 (dup1)))
    (mstore8 (add output_off))
    (jump mainLoop:start)

    ;; Deploying the contract
    (dest label:deploy)
    (log0 output_off (mload outLength))
    (return output_off (mload outLength))
    ))

(evm-assemble prog)
