module Key_mappings = Key_mappings
module Moves_parser = Moves_parser

exception ParseError of string

(** [parse_grammar_file path] reads a file and parses it into lists of key mappings and moves,
    exiting with specific errors for key mapping or move parsing issues. *)
let parse_grammar_file path =
  let key_mappings = ref [] in
  let move_sequences = ref [] in
  let ic = open_in path in
  let parsing_moves = ref false in
  try
    while true do
      let line = input_line ic |> String.trim in
      if String.length line = 0 then
        () (* Skip empty lines *)
      else if line = "--------------------" then (
        if !key_mappings = [] then
          raise (ParseError "No key mappings found in the grammar file.");
        parsing_moves := true
      )
      else if not !parsing_moves then
        match Key_mappings.parse_key_mapping line with
        | Some km -> key_mappings := km :: !key_mappings
        | None -> raise (ParseError ("Invalid key mapping: '" ^ line ^ "'"))
      else
        let defined_actions = List.map (fun km -> km.Key_mappings.action) !key_mappings in
        match Moves_parser.parse_move_sequence ic line defined_actions with
        | Some mv -> move_sequences := mv :: !move_sequences
        | None -> raise (ParseError ("Invalid move sequence: '" ^ line ^ "'"))
    done;
    close_in ic;
    (!key_mappings, !move_sequences)
  with
  | End_of_file ->
    close_in ic;
    (* Ensure moves are not empty after reaching EOF *)
    if !move_sequences = [] then
      raise (ParseError "No move sequences found in the grammar file.");
    (!key_mappings, !move_sequences)
  | ex ->
    close_in ic;
    raise ex

let process_grammar_file path =
  try
    let key_mappings, move_sequences = parse_grammar_file path in
    match Validator.validate_grammar key_mappings move_sequences with
    | Ok () -> (key_mappings, move_sequences)
    | Error msg -> raise (ParseError msg)
  with
  | ParseError msg ->
    print_endline ("Parsing error: " ^ msg);
    exit 1
  | ex ->
    (* Use pattern matching to print the exception message *)
    let error_msg = match ex with
      | Sys_error msg -> msg  (* This is for Sys_error exception *)
      | _ -> "Unexpected error occurred"  (* Handle any other type of error *)
    in
    print_endline ("Unexpected error: " ^ error_msg);
    exit 1

(** [show_key_mappings key_mappings] prints each key mapping in a human-readable format. *)
let show_key_mappings key_mappings =
  List.iter (fun km ->
    print_endline ("Key: '" ^ km.Key_mappings.key ^ "' -> Action: '" ^ km.Key_mappings.action ^ "'")  (* print_endline from Pervasives *)
  ) key_mappings

(** [show_moves moves] prints each move in a human-readable format. *)
let show_move_sequences moves =
  List.iter (fun mv ->
    print_endline ("Move Name: '" ^ mv.Moves_parser.name ^ "', Combo: [" ^
                   String.concat ", " mv.Moves_parser.key_combination ^ "]")  (* print_endline from Pervasives *)
  ) moves
