open Base
open Stdio

type key_mapping = { key : string; action : string }
type move = { name : string; key_combination : string list }

exception ParseError of string

(** [is_valid_key key] checks if a key is a single alphabetic character or a direction name. *)
let is_valid_key key =
  let directions = ["up"; "down"; "left"; "right"] in
  (String.length key = 1 && Char.is_alpha key.[0]) || List.mem directions key ~equal:String.equal

(** [parse_key_mapping line] parses a line into a [key_mapping] record :
    * Checks that the line has exactly three elements: [key; "->"; action].
    * Validates that [key] is a valid key.
    * Both key and action must be alphabetic. *)
let parse_key_mapping line =
  let parts = String.split ~on:' ' line in
  match parts with
  | [key; "->"; action]
    when is_valid_key key && String.for_all action ~f:Char.is_alpha ->
      Some { key = String.strip key; action = String.strip action }
  | _ -> None

(** [parse_move_sequence ic line defined_actions] parses lines to create a [move] record:
    * The combo starts with [ and ends with ].
    * Each element within key_combination must be a defined key action. *)
let parse_move_sequence ic line defined_actions =
  if String.length line > 2 && Char.(line.[0] = '[') && String.contains line ']' then
    let closing_bracket_index = String.index_exn line ']' in
    let combo_str = String.sub line ~pos:1 ~len:(closing_bracket_index - 1) in
    let key_combination = String.split ~on:',' combo_str |> List.map ~f:String.strip in
    let remaining =
      String.sub line ~pos:(closing_bracket_index + 1) 
                  ~len:(String.length line - closing_bracket_index - 1)
      |> String.strip
    in
    let name =
      if String.is_empty remaining then
        match In_channel.input_line ic with
        | Some next_line -> String.strip next_line
        | None -> ""
      else remaining
    in
    if List.for_all key_combination ~f:(fun action -> List.mem defined_actions action ~equal:String.equal) then
      Some { name; key_combination }
    else
      raise (ParseError (Printf.sprintf "Undefined action in move combination [%s]" combo_str))
  else
    None

(** [validate_key_mappings key_mappings] ensures no duplicate keys or actions exist. *)
let validate_key_mappings key_mappings =
  let keys = List.map key_mappings ~f:(fun km -> km.key) in
  let actions = List.map key_mappings ~f:(fun km -> km.action) in
  let duplicate_keys = List.contains_dup keys ~compare:String.compare in
  let duplicate_actions = List.contains_dup actions ~compare:String.compare in
  if duplicate_keys then
    Error "Duplicate keys found in key mappings."
  else if duplicate_actions then
    Error "Duplicate actions found in key mappings."
  else
    Ok ()

(** [validate_moves moves] ensures move names are unique. *)
let validate_moves moves =
  let move_names = List.map moves ~f:(fun mv -> mv.name) in
  if List.contains_dup move_names ~compare:String.compare then
    Error "Duplicate move names found."
  else
    Ok ()

(** [parse_grammar_file path] reads a file and parses it into lists of key mappings and moves,
exiting with specific errors for key mapping or move parsing issues. *)
let parse_grammar_file path =
  let key_mappings = ref [] in
  let move_sequences = ref [] in
  let ic = In_channel.create path in
  let parsing_moves = ref false in
  try
    In_channel.iter_lines ic ~f:(fun line ->
      let line = String.strip line in
      if String.is_empty line then
        () (* Skip empty lines *)
      else if String.equal line "--------------------" then (
        if List.is_empty !key_mappings then
          raise (ParseError "No key mappings found in the grammar file.");
        parsing_moves := true
      )
      else if not !parsing_moves then
        match parse_key_mapping line with
        | Some km -> key_mappings := km :: !key_mappings
        | None -> raise (ParseError (Printf.sprintf "Invalid key mapping: '%s'" line))
      else
        let defined_actions = List.map !key_mappings ~f:(fun km -> km.action) in
        match parse_move_sequence ic line defined_actions with
        | Some mv -> move_sequences := mv :: !move_sequences
        | None -> raise (ParseError (Printf.sprintf "Invalid move sequence: '%s'" line))
    );
    In_channel.close ic;
    (!key_mappings, !move_sequences)
  with
  | ex ->
    In_channel.close ic;
    raise ex

(** [validate_grammar key_mappings moves] performs all validations on parsed data. *)
let validate_grammar key_mappings moves =
  match validate_key_mappings key_mappings with
  | Error msg -> Error msg
  | Ok () -> (
      match validate_moves moves with
      | Error msg -> Error msg
      | Ok () -> Ok ()
    )

let process_grammar_file path =
  try
    let key_mappings, move_sequences = parse_grammar_file path in
    match validate_grammar key_mappings move_sequences with
    | Ok () -> (key_mappings, move_sequences)
    | Error msg -> raise (ParseError msg)
  with
  | ParseError msg ->
    eprintf "Parsing error: %s\n" msg;
    Stdlib.exit 1
  | ex ->
    eprintf "Unexpected error: %s\n" (Exn.to_string ex);
    Stdlib.exit 1

(** [show_key_mappings key_mappings] prints each key mapping in a human-readable format. *)
let show_key_mappings key_mappings =
  List.iter key_mappings ~f:(fun km ->
    printf "Key: '%s' -> Action: '%s'\n" km.key km.action
  )

(** [show_moves moves] prints each move in a human-readable format. *)
let show_move_sequences moves =
  List.iter moves ~f:(fun mv ->
    printf "Move Name: '%s', Combo: [%s]\n" mv.name (String.concat ~sep:", " mv.key_combination)
  )