open Base
open Stdio
open Parser

(* [check_file_input args] verifies that only one filename is provided 
    and checks if the file is accessible and readable. *)
let check_file_input args =
  match args with
  | [| _; filename |] ->
    (try
        Option.some_if (In_channel.with_file filename ~f:(fun _ -> true)) filename
      with
      | Sys_error err ->
        printf "Error: %s\n" err;
        None)
  | [| _; _; _ |] ->  
    printf "Error: Too many arguments provided. Please provide only one file as input.\n";
    None
  | _ -> 
    printf "Error: you need to provide one file as input.\n";
    None

let () =
  match check_file_input (Sys.get_argv ()) with
  | Some filename ->
    printf "File '%s' is ready for parsing.\n" filename;

    let key_tokens, move_tokens = process_grammar_file filename in
    printf "Key Mapping as Tokens:\n";
    List.iter key_tokens ~f:(fun token -> printf "%s\n" token);
    printf "\nMove Sequence as Tokens:\n";
    List.iter move_tokens ~f:(fun token -> printf "%s\n" token);

    printf "Parsing and Tokenisation are complete\n\n";
    
    (* At this stage @ellacroix you can use the tokens to test the finite automaton 
       if you want or need *)
    printf "Automaton start\n\n";
    let alphabet = ["up"; "down"] in
    let states = [0;1] in
    let transitions = [(0, "up", 1); (1, "down", 0)] in
    Automaton.automaton_loop alphabet states transitions


  | None ->
    printf "Error: Exiting program.\n";
    Caml.exit 1