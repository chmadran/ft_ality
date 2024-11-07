# ft_ality


## PROJECT INFO

This project is consists in two steps: training a finite state automaton, and running it. The automaton will be built at runtime, using grammar files that contain the moves to be learnt. 

## HOW TO RUN

`` make TODO ``

The program will wait for input from the keyboard, just like the training mode of a fighting game. So simply press keys on your keyboard, following the key mapping displayed on the screen, and move names should be displayed when their key combinations are executed.

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

FSAs are used in various applications, including parsing, network protocols, and text search algorithms. They’re powerful in pattern recognition but are limited to recognizing only regular languages.

</details>