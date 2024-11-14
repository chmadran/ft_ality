# ft_ality


## PROJECT INFO

This project is consists in two steps: training a finite state automaton, and running it. The automaton will be built at runtime, using grammar files that contain the moves to be learnt. 

## HOW TO RUN

`` make build ``
`` make run ARG="[GRAMMAR FILE]"``

The program will wait for input from the keyboard, just like the training mode of a fighting game. So simply press keys on your keyboard, following the key mapping displayed on the screen, and move names should be displayed when their key combinations are executed.

Inspiration for the grammar file : https://www.mksecrets.net/index.php?section=mk9&lang=eng&contentID=4796.   

## PROJECT FLOW
1. main.ml gets the arguments and check the file accessibility, and send it to Parser
   1. main.ml also handles all the input->function->output->function->output->function... flow
2. Parser reads the file line by line, verifying the syntax, get all moves then all combos and pass them as lists to Validator
3. Validate the moves and combos, and pass them to Trainer
   1. Check that there is no duplicates in moves
   2. Check that there are no duplicate combos and they only use moves from alphabet
4. Trainer receives the validated lists, builds the finite-state-automaton and pass it to Automaton:
   1. Alphabet
   2. States
   3. Transitions
5. Automaton reads input from the keyboard, evolve from state to state and print combos when they are performed


## PARSING 

The rules we defined for our grammar files are as follows :   

Line 0: key -> action\n   
Line 1: key -> action\n   
Line 2: X actions in between two brackets\n  
Line 3 : Combo name\n   
Line 4: Empty    
Line 5: X actions in between two brackets\n   
Line 6 : Combo name\n   
Line 7: Empty  
etc...  

**For Keys**    
* Character Check: Each key is a single alphabetical character or a valid directional word (only up, down, left, right).   
* Separator Check: Presence of the -> separator to ensure valid key mappings.    
* Carriage return Check: Presence of the \n separator between key mappings.   
* Uniqueness of Keys: Each key is mapped to only one action, rejecting duplicates.   


**Separator Line**     
* Presence of the separator line "------" to clearly mark the boundary between mappings and moves.

**For Moves**     
1. Combo Format:   
* The combo part is enclosed in two square brackets ([ ]).   
* Each combo contains valid keys (matching the defined keys from the mappings section).   
2. Move Naming: The move name follows the combo.   
3. Check Defined Keys: All keys in each combo are defined in the mappings section.   

**General Rules**
1. Special Character Rejection: Any special characters gets detected and triggers an error. We only accept alphabetic characters (and not alphanumeric why the hell would you wanna use numbers), brackets [ ], separator "->", and line separators (\n).  
2. Trim Excessive Whitespace: Extra spaces are removed to standardize input format.   
3. Limit on Move Count: Set maximum number of moves and mappings to 10 (even if it’s theoretical since there is already an alphabet-based limit on keys).   
4. Error Handling: If a line fails validation at any point, we exit the program immediately.    

## RESEARCH 

<details><summary>Language Theory</summary>

Also known as formal language theory, this is the branch of computer science theory that is a study of formal languages ie structured sets of symbols and rules, for their manipulation. 

Some core concepts include :

* Alphabets: A finite set of symbols. For example, {0, 1} is a common alphabet in binary systems.
* Strings: Sequences of symbols from an alphabet. For example, 101 is a string in the alphabet {0, 1}.
* Languages: Sets of strings formed from an alphabet, often constrained by specific rules. For example, {0, 1} could represent a binary language.
* Grammars: Formal systems that define languages by specifying production rules. These rules indicate how strings can be formed in a language. Context-free grammars, for example, are widely used in defining programming language syntax.
* Finite Automata: Abstract machines used to recognize patterns in languages. Automata theory provides models for how computers can process languages. For instance, a finite state machine can be used to check if a given string belongs to a language.
* Chomsky Hierarchy: A classification system for languages based on their complexity. It includes regular languages, context-free languages, context-sensitive languages, and recursively enumerable languages.

Language theory helps in designing programming languages and compilers but more importantly in the context of our project, in building parsers to analyze and interpret code or structured data. It assists creating algorithms for pattern matching. Language theory thus provides the fundamental principles for how computers interpret, analyze, and manipulate languages.

</details>


<details><summary>Formal Grammar</summary>

A formal grammar is a set of rules that define how strings in a language are constructed. Grammars are used to describe the structure of languages, often defining which strings (sequences of symbols) are valid within a particular language.

A grammar typically has:

* Non-terminals: Abstract symbols that can be replaced by sequences of other symbols.
* Terminals: The actual symbols in the language (e.g., letters, numbers).
* Production rules: Rules that define how non-terminals can be transformed into terminals or other non-terminals.
* Start symbol: The initial non-terminal from which strings in the language are derived.

For example, a formal grammar for a basic language that only includes numbers and addition operations (i.e., the sum of two numbers) would look like : 

```
Expr → Expr + Number | Number
Number → 1 | 2 | 3 | 4 | 5
```


</details>

<details><summary>The Chomsky Hierarchy</summary>

The Chomsky hierarchy categorizes formal grammars (and the languages they generate) into four types based on their complexity and the types of automata that can recognize them:

* Type 0: Recursively Enumerable Languages: Recognized by a Turing machine, these are the most general and powerful languages, but not all are decidable.
* Type 1: Context-Sensitive Languages: Recognized by a linear-bounded automaton, these languages have rules that consider the context of symbols in a sequence.
* Type 2: Context-Free Languages: Recognized by a pushdown automaton, these languages are widely used in programming languages, where each rule only depends on one non-terminal.
* Type 3: Regular Languages: Recognized by a finite automaton, these are the simplest languages with rules of the form A → aB or A → a and are used in search patterns or simple syntax.

</details>

<details><summary>Regular Languages (or Type 3 Languages) </summary>

Regular languages are the simplest type of languages in the Chomsky hierarchy, and they can be described by regular expressions or finite automata. They are "type 3 languages" because they belong to the lowest, simplest level in the hierarchy.

Characteristics of regular languages:

* Finite-state: They can be fully represented by a finite number of states.
* Limited memory: They don’t require a memory stack or recursion for parsing.

Examples include sets of strings like all binary strings that end in 0 (e.g., 10, 110, etc.).
Regular languages are commonly used in search algorithms, text processing, and lexical analysis (e.g., searching for patterns in text using regular expressions).

</details>

<details><summary>Finite-State Automata (Finite-State Machines) </summary>

A finite-state automaton (FSA) is an abstract machine that processes regular languages. It operates by moving between a finite number of states based on the input symbols and is commonly used to recognize patterns and regular languages.

An FSA consists of:

* States: Different "conditions" the machine can be in.
* Alphabet: The set of symbols it recognizes.
* Transitions: Rules that define how the machine moves from one state to another based on input symbols.
* Start state: The initial state where processing begins.
* Accept states: States that indicate successful recognition of a string.

Example: An FSA for the language of binary strings ending in 0 would move between states to accept strings like 10, 110, but reject 11.

FSAs are used in various applications, including parsing, network protocols, and text search algorithms. They’re powerful in pattern recognition but are limited to recognizing only regular languages. In our case, the FSA will be represented by a tuple `A = (Q, Σ, Q₀, F, δ)` : 

`Σ` is the input alphabet. It's the set of symbols or characters that the automaton can read. Think of it as the "vocabulary" the automaton understands.
Example: If the FSA is designed to recognize words made of the letters a and b, then Σ = {a, b}.

`Q` is the set of states in the automaton. A state is like a "status" the automaton can be in at any given time. The system switches between different states based on what it reads.
Example: An FSA that checks if a string has an even or odd number of as might have two states: even and odd.
Example: Q = {even, odd}

`Q₀` is the starting state. It’s the state where the automaton begins when it starts processing an input. So, when the automaton starts, it's in Q₀.
Example: If the starting state is the even state (where the automaton has seen an even number of as so far), then Q₀ = even.

`F` is the set of final or accepting states. These are the states that the automaton considers "successful" or "accepted" when it finishes reading the input. If the automaton ends in a state from F, it means the input is accepted by the automaton.
Example: If the automaton accepts strings that contain an even number of as, then F = {even}, because it should be in the even state when the string is accepted.

`δ` is the transition function. It tells the automaton how to move from one state to another based on the current state and the symbol it reads. It is a function that takes in a state and a symbol from the input alphabet and returns the next state.
Example: If the automaton is in the even state and reads the symbol a, it should transition to the odd state. If it's in the odd state and reads a, it should go back to the even state.

So, δ might look something like this:

* δ(even, a) → odd
* δ(odd, a) → even
* δ(even, b) → even
* δ(odd, b) → odd

It’s a function that tells you the next state for each symbol you encounter.

</details>

<details><summary>Functional Programming</summary>

You only look at input and produce output, no side effects.
* But in Ocaml we can still cheat a bit to print() for example, to produce side effects.

There are two main things you need to know to understand the concept:

* Data is immutable: If you want to change data, such as an array, you return a new array with the changes, not the original.
* Functions are stateless: Functions act as if for the first time, every single time! In other words, the function always gives the same return value for the same arguments.

There are three best practices that you should generally follow:

1. Your functions should accept at least one argument.
2. Your functions should return data, or another function.
3. Don’t use loops!

No concatenation of commands
* ex: do_thing1(); do_thing2()
Instead, composition of functions
* ex: print(sum(2, exp(1,2)))

Posts
* [Github Functional Programming 101](https://github.com/readme/guides/functional-programming-basics)

Videos
* [Functional Programming in 40 Minutes • Russ Olsen • GOTO 2018](https://www.youtube.com/watch?v=0if71HOyVjY)
  * You can stop at 30 minutes
  
</details>