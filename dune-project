(lang dune 3.16)
(using coq 0.4)
(using mdx 0.2)
(name iris-wasm)
(version 2.0)

(generate_opam_files true)
(license MIT)
(source (github logsem/iriswasm))

(package
  (name iris-wasm)
  (synopsis "Wasm formalisation in Coq and Iris")
  (description "Wasm formalisation in Coq, following the AFP formalisation of Conrad Watt, and program logic for Wasm using Iris")
  (depends
   (coq (>= 8.20.1))
    (coq-iris (>= 4.3.0))
    (coq-stdpp (>= 1.11.0)) 
    (coq-compcert (>= 3.15))
    (coq-ext-lib (>= 0.13.0))
    (coq-mathcomp-ssreflect (>= 2.3.0))
    (coq-parseque (>= 0.2.1))
    (coq-itree (>= 5.2.0))
    (cmdliner (>= 1.3.0))
    (linenoise (>= 1.5.1))
    (mdx (>= 2.5.0))
    )	 
  (maintainers
    Maxime Legoupil
    )
  (authors
    Rao XiaoJia
    Aina Linn Georges
    Maxime Legoupil
    Jean Pichon-Pharabod
    Conrad Watt
    Philippa Gardner
    Lars Birkedal
  )
  )



(warnings (deprecated_coq_lang_lt_08 disabled))
