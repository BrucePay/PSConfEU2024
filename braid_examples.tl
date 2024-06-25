;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Braidlang examples
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; list directory
(ls)

;list only file
(ls -file)

; get total size of files, PowerShell style

(ls -file | foreach-object | measure-object -sum | foreach sum)

; braid style

(ls -file | map .length | sum)

; or

(ls -file | sum .length) 

; with a lambda

(ls -file | sum (\ f -> (.length f)))

; performance

(time (fib 20)) ; naive factorial in braid

(time (psfib 20)) ; naive factorial in PowerShell

; looping in braid - foreach is a function. not a keyword

(time 10 (foreach i (range 1 1000)))

; a vector
[1 2 3]

; a vector with splatting
[1 @(range 2 9) 10]

; dictionary
{"foo" 1 "bar" 2 }

; set
#{"red" "blue" "green" }

; list functions
(range 10 | map (\ n -> (* n n))
(range 10 | filter (% 2))
(reduce (range 10) *)
(range 10 | reduce *)

; pattern matching
(defn fib
    | 1 -> 1
    | 2 -> 1
    | n -> (fib (- n 1) | + (fib (- n 2)))
)

; destructuring 

(let [head &rest] [1 2 3]) ; with a vector

(let h:tail [1 2 3]) ; shorthand

; looping in PowerShell
(let sb (create-scriptblock """ foreach ($i in 1..10000) {} """))
(time 10 (sb))

; explicit tail-call optimizations with recur
(defn my-count
    | nil (c 0) -> c
    | x:xs (c 0) -> (recur xs (++ c))
)

; example functions

(defn bls
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

    (bls path "*" true
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
