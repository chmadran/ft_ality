open Base
open Stdio
open Parser
open Automaton

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
    (* let alphabet = {"up": "Up"; "down": "Down"} in
    let accepting_states = [0;1] in
    let transitions = [(0, "up", 1); (1, "down", 0)] in *)
    let alphabet = [{key = "up"; action = "Up"}; {key = "right"; action = "Forward"}; {key = "down"; action = "Down"}; {key = "left"; action = "Backward"};
					{key = "q"; action = "Punch"}; {key = "w"; action = "Kick"}; {key = "e"; action = "Throw"}] in
    let accepting_states = [{name = "Front Punch !!"; key_combination = ["Punch"; "Forward"]}; {name = "Back Punch !!"; key_combination = ["Punch"; "Backward"]};
							{name = "Front Kick !!"; key_combination = ["Kick"; "Forward"]}; {name = "Back Kick !!"; key_combination = ["Kick"; "Backward"]};
							{name = "Flip Stance !!"; key_combination = ["Throw"; "Backward"]}; {name = "Block !!"; key_combination = ["Backward"; "Forward"]}] in
    let transitions = [{state = ["Initial"]; key_pressed = "Punch"; next_state = ["Punch"]}; {state = ["Punch"]; key_pressed = "Forward"; next_state = ["Punch"; "Forward"]}] in
    Automaton.automaton_loop alphabet accepting_states transitions


  | None ->
    printf "Error: Exiting program.\n";
    Caml.exit 1