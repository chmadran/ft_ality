module Key_mappings = Key_mappings
module Moves_parser = Moves_parser

exception ParseError of string

(** [parse_grammar_file path] reads a file and parses it into lists of key mappings and moves,
    exiting with specific errors for key mapping or move parsing issues. *)
let parse_grammar_file path =
  let key_mappings = ref [] in
  let move_sequences = ref [] in
  let ic = Stdio.In_channel.create path in
  let parsing_moves = ref false in
  try
    Stdio.In_channel.iter_lines ic ~f:(fun line ->
      let line = Base.String.strip line in
      if Base.String.is_empty line then
        () (* Skip empty lines *)
      else if Base.String.equal line "--------------------" then (
        if Base.List.is_empty !key_mappings then
          raise (ParseError "No key mappings found in the grammar file.");
        parsing_moves := true
      )
      else if not !parsing_moves then
        match Key_mappings.parse_key_mapping line with
        | Some km -> key_mappings := km :: !key_mappings
        | None -> raise (ParseError (Printf.sprintf "Invalid key mapping: '%s'" line))
      else
        let defined_actions = Base.List.map !key_mappings ~f:(fun km -> km.action) in
        match Moves_parser.parse_move_sequence ic line defined_actions with
        | Some mv -> move_sequences := mv :: !move_sequences
        | None -> raise (ParseError (Printf.sprintf "Invalid move sequence: '%s'" line))
    );
    Stdio.In_channel.close ic;
    (!key_mappings, !move_sequences)
  with
  | ex ->
    Stdio.In_channel.close ic;
    raise ex

let process_grammar_file path =
  try
    let key_mappings, move_sequences = parse_grammar_file path in
    match Validator.validate_grammar key_mappings move_sequences with
    | Ok () -> (key_mappings, move_sequences)
    | Error msg -> raise (ParseError msg)
  with
  | ParseError msg ->
    Stdio.eprintf "Parsing error: %s\n" msg;
    Stdlib.exit 1
  | ex ->
    Stdio.eprintf "Unexpected error: %s\n" (Base.Exn.to_string ex);
    Stdlib.exit 1

(** [show_key_mappings key_mappings] prints each key mapping in a human-readable format. *)
let show_key_mappings key_mappings =
  Base.List.iter key_mappings ~f:(fun km ->
    Stdio.printf "Key: '%s' -> Action: '%s'\n" km.Key_mappings.key km.Key_mappings.action
    )

(** [show_moves moves] prints each move in a human-readable format. *)
let show_move_sequences moves =
  Base.List.iter moves ~f:(fun mv ->
    Stdio.printf "Move Name: '%s', Combo: [%s]\n" mv.Moves_parser.name (Base.String.concat ~sep:", " mv.Moves_parser.key_combination)
  )
