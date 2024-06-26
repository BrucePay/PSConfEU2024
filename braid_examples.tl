;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Braidlang examples
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; list directory
(ls)

;list only files
(ls -file)

; get total size of files, PowerShell style

(ls -file | foreach-object | measure-object -sum | foreach sum)

; get total size of files, Braid style

(ls -file | map .length | sum)

; or more simply

(ls -file | sum .length) 

; with an explicit lambda

(ls -file | sum (\ f -> (.length f)))

; "Operators" are also functions and used with prefix notation. 

(+ 1 2 3 4)     ; sum a bunch of numbers
(* 1 2 3 4)     ; multiply a bunch of numbers

; Using '*' to create s factorial function. (The @ splats the collection as arguments.)
(defn fact [n] (* @(range n)))

; Some Braid vs Powershell performance

(time (fib 20))   ; naive factorial in braid

(time (psfib 20)) ; naive factorial in PowerShell

; looping in braid - As always, foreach is a function. not a keyword

(foreach i (range 1 1000) (println i))

; A vector literal
[1 2 3]

; which is just a syntactic short-cut for
(vector 1 2 3)


; Creating a vector with splatting
[1 @(range 2 9) 10]

; or using the vector function
(vector 1 @(range 2 9) 10)

; A dictionary literal
{"foo" 1 "bar" 2}

; A set literal
#{"red" "blue" "green" }

; Braid has the usual list functions
(range 10 | map (\ n -> (* n n)))    ; returns the list squared
(range 10 | filter (% 2))            ; returns the odd number`
(reduce (range 10) *)A               ; multiply all the numbers together
(range 10 | reduce *)

; Destructuring collections (lists, vector)
(let [h &t] [1 2 3]) ; in this example, h will become 1 and t will be [2 3]

(let h:t [1 2 3])    ; shorthand with a 'compound' symbol

; Braid supports pattern matching functions
(defn fib
    | 1 -> 1
    | 2 -> 1
    | n -> (fib (- n 1) | + (fib (- n 2)))
)

; and basic functions
(defn fib [n]
    (if (< n 2)
        1
        (+ (fib (- n 1)) (fib (- n 2)))
    )
)

; Define functions with explicit tail-call optimizations using the recur function.

; a function to count the elements in a list using destructuring and recur
(defn my-count
    | nil (c 0) -> c
    | x:xs (c 0) -> (recur xs (+ c 1))
)

; Count a list of 10000 numbers. Without tail-call optimization, this
; would overflow the call stack.
(range 10000 | my-count)


; Braid has macros. In this case '=' parses it's arguments as an expression
; the returns the prefix form
echo (\ -> (= 2+2*3))

;====================================================
; Some more complex example functions

(defn dls
"Recursively list all the directories in a tree."
    [(^string path ".") (^string pattern "*") (^bool recurse false)]

    (if (not path)
        (return [])
    )

    (let option
        (if recurse
            .System.IO.SearchOption/AllDirectories
            .System.IO.SearchOption/TopDirectoryOnly
        )
    )

    (.IO.Directory/GetDirectories path pattern option)
)

(defn ffind
"Search for files matching the pattern"
    [(^string pattern) (^string path ".")]

    (dls path "*" true
    |  flatmap (\ f -> (.io.directory/getfiles f pattern))
    )
)

(defn line-count
"Count the number of lines in a set of files matching the supplied extension"
    [(^string path ".") (^string ext "*.CS")]

    (bls path "*" true
    | flatmap (\ f -> (.io.directory/getfiles f ext))
    | sum (\ f -> (read-file f #"[a-z0-9]" | count))
    )
)

