module Key_mappings = Parser.Key_mappings
module Moves_parser = Parser.Moves_parser

(* [check_file_input args] verifies that only one filename is provided 
   and checks if the file is accessible and readable. *)
let check_file_input args =
  match args with
  | [| _; filename |] ->
    (try
       let ic = open_in filename in
       close_in ic;
       Some filename
     with
     | Sys_error err ->
       print_endline ("Error: " ^ err);
       None)
  | _ ->
    print_endline "Error: Please provide exactly one file as input.";
    None

let () =
  match check_file_input (Sys.argv) with
  | Some filename ->
    print_endline ("Parsing file '" ^ filename ^ "'...");
    let key_mappings, move_sequences = Parser.process_grammar_file filename in

    print_endline "Key Mappings:";
    List.iter (fun km ->
      print_endline (km.Key_mappings.key ^ " -> " ^ km.Key_mappings.action)
    ) key_mappings;

    print_endline "\nMoves:";
    List.iter (fun mv ->
      print_endline (mv.Parser.Moves_parser.name ^ ": [" ^ String.concat ", " mv.Parser.Moves_parser.key_combination ^ "]")
    ) move_sequences;

    let transitions = Trainer.create_transitions move_sequences in

    Automaton.automaton_loop key_mappings move_sequences transitions

  | None -> exit 1
