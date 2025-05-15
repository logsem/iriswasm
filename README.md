
# Iris-Wasm

This directory includes the supplementary artefact for the paper *Iris-Wasm: Robust and Modular Verification of WebAssembly Programs*, a submission to the **44th ACM SIGPLAN Symposium on Programming Language Design and Implementation (PLDI 2023)**.

  

# Getting Started Guide

## Browsing the Proofs

Once the project has been compiled (see step-by-step instructions), the proofs can be browsed using Emacs and Proof General. For example,

```bash
emacs theories/iris/examples/iris_examples.v
```

opens the file containing some direct examples of using the program logic in Emacs. Other proofs can be browsed similarly. 

## Basic Testings

For some basic testing, the key stack example described in the paper resides in `theories/iris/examples/stack/`, with each of its module function implemented and verified in an individual file under `theories/iris/examples/stack/function/`. We invite the reviewers to run through the code and the fully-proved specifications of each function, which are omitted in the paper due to space constraint. The stack module `stack_module` itself is implemented and verified in `theories/iris/examples/stack/stack_instantiation.v`, importing its module functions.

## Line of Code Prints
To check against the line of code (LOC) table given in Fig. 4 (Line 736) of the paper, run `make loc` which will prints out a tally of LOC as given by the `cloc` command for each subdirectory under `theories/iris/`. Note that the `examples` folder contains both the *examples* and *stack* entry in the table, which is the correct sum (11541 = 2754 + 8787). This command uses `cloc`, which can be installed via:
```bash
apt install cloc
```



# Step-by-Step Instructions

## Manual Installation and Compilation

The project can be installed using opam.

We recommend creating a new switch to start from a clean environment. The newest versions of ocaml are incompatible with our required version of Coq. We have compiled the project with version 4.14.2. The following code creates a switch with the necessary version:
```bash
opam switch create iris-wasm-artifact-switch ocaml.4.14.2
```

Depending on the opam configuration, it may be necessary to manually switch to the newly created switch:
```bash
opam switch iris-wasm-artifact-switch
eval $(opam env --switch iris-wasm-artifact-switch --set-switch)
```

The following code fetches all necessary dependencies from opam and compiles the development:
```bash
opam repo add coq-released https://coq.inria.fr/opam/released
opam install .
```

If all necessary packages are present in the opam environment, the development can also be compiled by running
```bash
make
```

Compiling the development requires at least 8GB of RAM and may take over 30 minutes.

## Browsing the Proofs

Browsing proofs can be done conveniently in emacs. For example:

```bash
esy theories/iris/examples/iris_examples.v
```
This opens the file containing some direct examples of using the program logic in Emacs, assuming Emacs and Proof General are installed. Other proofs can be browsed similarly. Emacs can be installed via command line:
```bash
apt install emacs
```

The instruction to install Proof General can be found at https://proofgeneral.github.io.

Although not necessary, we also recommend installing the Company-Coq plugin for pretty printing and easier editing to the proofs. The instruction to install Company-Coq can be found at https://github.com/cpitclaudel/company-coq. Company-Coq is pre-installed in the VM image provided.

### Troubleshooting

If running `make` fails, the issue is likely a missing package in opam, or a package with the wrong version. Check what version of each package opam has registered by running `opam list`. A list of necessary packages and the requirements on their versions can be found in the `dune-project` file; in case of a discrepancy, the correct version can be manually installed.

Missing packages, or packages with the wrong version, can be installed manually using `opam install`. For instance, to get the correct version of `coq-iris` or `mdx`, run:
```bash
opam install coq-iris.4.3.0
opam install mdx.2.5.0
```

Some packages are in the `coq-released` repository; in order to let opam know where to fetch these, before running `opam install` run:
```bash
opam repo add coq-released https://coq.inria.fr/opam/released
```

A shorthand to install all missing dependencies and compile the development is:
```bash
opam install .
```

### Warnings that are Safe to Ignore

When browsing the proofs in Emacs + Proof General, a warning on boolean coercion will pop up in the Coq response prompt when the theorem prover runs past the imports. This is because two of our dependencies, ssreflect and stdpp, each implements its own coercion of Bool into Prop, resulting in ambiguous coercion paths. However, this can be safely ignored since the two implementations are essentially the same.


## Claims Supported and Not Supported by the Artefact
This artefact is a fully-verified implementation in Coq of the program logic proposed in the paper supporting all claims of the paper. Some simplification has been made in the presentation of the paper for space constraints, and we have tried our best to highlight all such differences in the section `Differences with Paper` in the end.

We invite the reviewer to compare the key claims made in the paper against the code for a demonstration of completeness. We suggest starting from the stack example, which is the main running example in the paper, and then the other examples and the implementation of the program logic itself if interested. The detailed locations and an outline of them can be found under the `Structure` section below.

The remaining part of this readme aims to explain the structure of the artefact, and provide directories and paths to locate the items that have appeared in the paper.



# Directories

For each figure and theorem in the paper, we provide the approximate paths, names, and line numbers (where applicable), under `theories/`, to indicate the location of them in the code. We also provide a general pointer for each subsection in Section 2 and Section 3 for the related files in the codebase. For a detailed breakdown of the code structure, see the `Structure` section later.

| Location in Paper | Location in Code |
|--|--|
| Fig. 1 | `iris/examples/stack/stack_instantiation.v` (`stack_module`, line 34), `iris/examples/stack/stack_client.v` (`client_module`, line 61)  | 
| Fig. 2 | `datatypes.v` | 
| Section 2.1 | `iris/language/iris.v`, `iris/rules/iris_rules_pure.v` | 
| Section 2.2 | `iris/rules/`, `iris/examples/stack/function/push.v` | 
| Section 2.3 | `iris/rules/`, `iris/examples/stack/function/stack_map.v` | 
| Section 3 | `iris/host/`, `iris/instantiation/`, `iris/examples/stack/` | 
| Fig. 3 | `iris/iris_host.v` | 
| Lemma 3.1 | `iris/instantiation/iris_instantiation.v` (`instantiation_wasm_spec`, line 3711) |
| Fig. 5 | `iris/examples/stack/stack_robust.v` (`client_module`, line 43; `stack_adv_client_instantiate`, line 503) | 
| Section 5 | `iris/logrel/`, `iris/examples/stack/` | 
| Theorem 5.1 | `iris/logrel/iris_interp_instance_alloc.v` (`interp_instance_alloc`, line 1978) |
| Theorem 5.2 | `iris/examples/stack/stack_robust.v` (`instantiate_client`, line 512)| 
| Theorem 5.3 | `iris/examples/stack/function/{push/pop/new_stack.v}` (`valid_{push/pop/new_stack}`}) |
  

# Structure

In this section, we describe the structure of the implementation.

  
## Native WebAssembly

Our work uses the mechanisation of WebAssembly 1.0 by Watt et al. in *Two Mechanisations of WebAssembly, FM21*. As a result, our work inherits many files from Watt et al's mechanisised proofs. These files are located directly under `theories` and are not claimed as part of contributions of this paper. We bring up the files most related to our work for completeness:

- `datatypes.v` contains all the basic WebAssembly data types definitions;

- `opsem.v` defines the operational semantics of WebAssembly;

- `typing.v` defines the type system for WebAssembly instructions, closures, and stores, and configurations.

- `instantiation.v` contains the definition of the module instantiation predicate in the official specification, as well as all the sub-predicates it depends on.

We chose to leave most parts of these files intact, except for our only slight reformulation of the host function implementation by adding the AI_call_host administrative instruction (as discussed in the paper), which caused some slight adaptations.

Our contribution in this work resides almost entirely under `theories/iris`.


## Defining the WebAssembly Language in Iris

Under `theories/iris/language`, we fit WebAssembly language into the Iris Language framework, prepare the preambles for our program logic and logical relation.


- `iris.v`: fits WebAssembly into an Iris Language by defining the logical values, expressions, and proving the necessary properties for them etc.;

- `iris_locations.v`: sets up the necessary details to express and manipulate the memory model of the language;

- `iris_wp.v`, `iris_wp_def.v`: sets up a custom weakest precondition to be used for our language, which differs slightly from the standard construct that Iris provides; defines the memory model of the language;

- `iris_adequacy.v`: contains a proof to the adequacy of our weakest precondition;

- `iris_atomicity.v`: contains a definition of which expressions are considered atmomic in Iris, and proves the definition is sound.

  

## Helper Properties for the Language

  
Under `theories/iris/helpers`, we established a lot of auxiliary properties about either the WebAssembly Semantics itself, or the plugging-in version of the semantics in Iris.

  

## Proof Rules for Native WebAssembly

  

Under `theories/iris/rules`, we proved a vast number of proof rules that can be used to reason about WebAssembly programs. We have categorised the proof rules into a few files, according to their nature:

  

- `theories/iris/rules/iris_rules_pure.v`: contains proof rules for *pure* instructions, i.e. those whose reduction semantics are independent from the state (for example, the `wp_binop` rule in Line 260);

- `theories/iris/rules/iris_rules_control.v`: contains proof rules for control instructions;

- `theories/iris/rules/iris_rules_resources.v`: contains proof rules that directly access the state, such as memory instructions;

- `theories/iris/rules/iris_rules_call.v`: contains proof rules related to function calls;

- `theories/iris/rules/iris_rules_structural.v`: contains structural proof rules to deal with sequencing of instruction sequences, possibly within evaluation contexts;

- `theories/iris/rules/iris_rules_trap.v`: contains structural proof rules that allow reasoning when a part of the expression produce traps.

- `theories/iris/rules/iris_rules_bind.v`: contains several bind rules for binding into evaluation contexts;

- `theories/iris/rules/iris_rules.v`: imports everything above, allowing users to import all proof rules at the same time more easily.

  

## Host Language and Instantiation Lemma

  

Under `theories/iris/instantiation`, we build up the module instantiation resource update lemma (Lemma 2.1), which is later imported to establish the instantiation proof rule in our host language.

  

Under `theories/iris/host`, we build our host language introduced in Section 2.4 and establish a set of proof rules for the host language required for reasoning about our examples.

  
  

## Logical Relation

  

Under `theories/iris/logrel/`, we build a logical relation on top of the program logic we've established.

  

- `iris_logrel.v`: contains the definition of all logical relations, starting from the simple relations for *values* and building up to sophisticated relations for *module instances* and expressions, contains the semantic typing definitions, and a generalised host integration record that defines the minimal requirements on a host program logic (note that it does not define restrictions on the host language itself, just the program logic). This file is the base of the logical relation.

- `iris_fundamental_(xxx).v`: each of these files contains the proof to a case of the Fundamental Theorem for one single instruction.

- `iris_fundamental.v`: imports all the case files above and derive the Fundamental Theorem (Theorem 3.2) in the paper, and its corollaries.

- `iris_interp_instance_alloc.v`: proves the module instantiation allocates the correct Iris invariants as expected, which is used for the robust safety examples later.

  

## Examples

Under `theories/iris/examples/`, we formulated the examples for our project, some of which were discussed in the paper. We bring up the key files below:

  
- `iris_examples.v`: contains several simpler preliminary examples to help understand the program logic without involving modules and the host language.

- `iris_examples_factorial.v`: contains the Landin's Knot example, where a factorial is implemented through store recursion.

- `stack/function/(function_name).v`: provides the body of the functions declared in the stack module, proves a specification for them within our program logic, and proves the validity result for some of the functions;

- `stack/stack_instantiation.v`: defines the stack module and proves its instantiation specification.

- `stack/stack_client.v`: defines a client module that can use imports from the stack module and proves its instantiation specification.

- `stack/stack_common.v`: includes some useful definitions and properties that are shared across the stack example.

- `stack/stack_with_reentrancy.v`: defines a more sophisticated client module that features a reentrant host call to demonstrate interoperation between the WebAssembly the the host weakest precondition.

- `stack/stack_robust.v`: defines yet another client module that imports an unknown module in addition to the stack module, and demonstrates the encapsulation property that can be obtained (discussed in Section 5).

- `stack/stack_module_robust.v`: similar to the above, but no known client is defined; instead an adverserial module imports the stack module. The stack invariant can still be preserved nevertheless.

The following are other examples that were not discussed in the paper.

- `iris_robust_examples.v`: a simpler robust safety example, containing an example host program which instantiates an adversary module followed by a trusted module. The trusted module calls an imported function from the unknown adversary module. We then demonstrate the robust safety property, where we have local state encapsulation in the presence of unknown code.

- `iris_robust_example_host.v`: contains a variation of the above example, in which the adversary module imports a host function. The example demonstrates the integration between the logical relation and the host language.

- `iris_robust_examples_adequacy.v`: applies adequacy on the above example.




# Differences with Paper

  

## Definitions

  

The definitions within our work were designed in a way that would fit best in an interactive proof environment, to facilitate sustainable engineering in the long term. Therefore, some definitions, especially the constructors of inductive and records, are either named or designed in a verbose way.

  

There are two major categories of differences:

  

### Removing naming prefixes

  

In the code, we exercise a naming convention for most constructors of inductive definitions and record by adding prefixes to them, so that it is possible to deduce the source of these constructors by looking at the prefix. Oftentimes these prefixes are in acronyms of the source definition (for example, `BI_` for each constructor of basic instructions).

  

### Removing trivial constructors

  

The large records in WebAssembly often involve fields of the same type (for example, in the `instance` definition, the addresses of `functions`, `tables`, `memories`, and `globals` are all immediate (isomorphic to naturals). In the code, we sometimes add another layer of constructor for each of them when unintended uses are possible (for example, looking up in `tables` by using a `memory` export reference).

  

### Other differences in names

  

We provide a list of some other name differences in names below:


| References in Paper | Definition in Code |
|--|--|
| Fig. 2, Instruction | `datatypes.v`: `basic_instruction` (line 301) |
| Line 248, Logical value | `iris/language/iris.v`: `val` (line 15) |
| Fig. 3, import variable store | `iris/host/iris_host.v`: `vi_store` (line 18) |
| Fig. 3, declaration | `iris/host/iris_host.v`: `host_e` (line 26) |
| Fig. 3, `inst_decl` | `iris/host/iris_host.v`: `ID_instantiate` (line 27) |
| Line 410, `wp_local_bind` | `iris/rules/iris_rules_bind.v`: `wp_frame_bind` (line 13)  |

  

  

  

## Names of Predicates

|Location in Paper| Name in Paper | Definition in Code |
|--|--|--|
|Lemma 3.1| `stateInterp` | `iris/language/iris_wp_def.v`, `gen_heap_wasm_store` (line 65) |
|Lemma 3.1| `resourcesImports` | `iris/instantiation/iris_instantiation.v`, `instantiation_resources_pre_wasm` (line 1468) |
|Lemma 3.1, Theorem 5.1| `resources` | `iris/instantiation/iris_instantiation.v`, `instantiation_resources_post_wasm` (line 1727) |
|Theorem 5.1| `I[[C]]` | `iris/logrel/iris_logrel.v`, `interp_instance` (line 291) |
|Theorem 5.3| `Clos` | `iris/logrel/iris_logrel.v`, `interp_closure` (line 205) |

  

## Differences in WP rules and lemmas

- WP rules and frame resource : the frame resource is occasionally put under a magic wand rather than in postcondition; the two presentations are equivalent in use.

- `wp_ctx_bind` (Line 327 in paper, `iris/rules/iris_rules_bind.v` in code) : the bind rule presented in the paper is intended for evaluation contexts with at least one label, and it is thus required that `es` constitutes the full base layer in `lh[es]` (i.e. that `lh` has an empty base layer). Similar structural rules for sequencing have also been proved.

- `wp_local_bind` (Line 410 in paper, `wp_frame_bind` in `iris/rules/iris_rules_bind.v` in code)  : the local bind rule requires the inner body `es` to be reducible (if `es` were already a value, the bind is not necessary anyway, as the entire expression is already a logical value).

- `inst_decl` (Line 591 in paper, `ID_instantiate` in code) : the order of arguments are reversed compared to the paper; in Coq it goes `ID_instantiate exports modules imports` which follows a style closer to the JS-Wasm API.

- Theorem 5.1: Note that the theorem in Coq code (`interp_instance_alloc`) is actually slightly stronger, as it *remembers* some of the values that the instance relation binds under existential quantifiers.

- Theorem 5.1: The predicate `valid[[timps]](imps)` is only used in `interp_instance_alloc` in `iris/logrel/iris_interp_instance_alloc.v`, which is a shorthand (for readability) of the unfolded versions that map over imported functions, tables and memories, and applies the relevant `interp_*` definition on each (line 2005-2007, `iris/logrel/iris_inetrp_instance_alloc`):

```
([∗ map] _↦cl ∈ wfs, interp_closure hl (cl_type cl) cl)\%I ∗
([∗ map] n↦t ∈ wts, interp_table (tab_size t) (interp_closure_pre C wfs inst hl) n) ∗
([∗ map] n↦m ∈ wms, interp_mem n)
```
 
Note again that the theorem stated and proved in Coq is stronger than theorem 5.1 is in the paper, since the globals are not assumed to be in the value relation. The reason is, that because of the assumed initialisation, validity of globals can be established in the proof itself, rather than needing to be assumed.

- Theorem 5.3: This is a combination of three lemmas located in three files as stated in the Directories section: `valid_push`, `valid_pop` and `valid_new_stack`, which are stated as one in the paper for convenience (without loss of generality). Note that there are also corresponding lemmas for `is_empty` and `is_full` which were not described in the paper (for simplicity).

- Theorem 5.3: The `stackInvariant` predicate refers to the Iris non-atomic invariant wrapping the `stackModuleInv` definition in `iris/examples/stack/stack_common.v`. Concretely, it is the statement 

```
na_inv logrel_nais stkN (stackModuleInv (λ (a : N) (b : seq.seq i32), isStack a b m) (λ n : nat, N.of_nat m↦[wmlength] N.of_nat n))
```

where `stkN` is a namespace defined in `stack_common.v` as well. Example of this statement can be found at line 393 of `iris/examples/stack/function/push.v` as a premise of `valid_push`.




