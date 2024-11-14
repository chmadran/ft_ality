open Base
open Stdio

type key_mapping = { key : string; action : string }
type move = { name : string; key_combination : string list }

(** [parse_key_mapping line] parses a line into a [key_mapping] record :
    * check that the parts list has exactly three elements: [key; "->"; action]
else it gets ignored. 
    * key is a valid character (alphabet or direction word), with no special characters.
*)
let parse_key_mapping line =
  let parts = String.split ~on:' ' line in
  match parts with
  | [key; "->"; action] when String.for_all key ~f:Char.is_alpha ->
      Some { key = String.strip key; action = String.strip action }
  | _ -> None


(** [parse_move_sequence ic line] parses lines to create a [move] record : 
    * the combo starts with [ and ends with ].
    * each element within key_combination is a defined key *)
let parse_move_sequence ic line defined_keys =
  if String.length line > 2 && Char.(line.[0] = '[') && String.contains line ']' then
    let closing_bracket_index = String.index_exn line ']' in
    let combo_str = String.sub line ~pos:1 ~len:(closing_bracket_index - 1) in
    let key_combination = String.split ~on:',' combo_str |> List.map ~f:String.strip in
    
    let remaining = String.sub line ~pos:(closing_bracket_index + 1) 
                                ~len:(String.length line - closing_bracket_index - 1)
                      |> String.strip in
    let name =
      if String.is_empty remaining then
        match In_channel.input_line ic with
        | Some next_line -> String.strip next_line
        | None -> ""
      else remaining
    in
    (* Check that the key_combination contains only defined keys *)
    if List.for_all key_combination ~f:(fun key -> List.mem defined_keys key ~equal:String.equal) then
      Some { name; key_combination }
    else
      None
  else
    None
    
    

(** [tokenize_key_mapping km] converts a [key_mapping] record into a list of tokens *)
let tokenize_key_mapping (km: key_mapping) : string list =
  [km.key; km.action]

(** [tokenize_move mv] converts a [move] record into a list of tokens *)
let tokenize_move (mv: move) : string list =
  mv.key_combination @ [mv.name]    

(** [parse_grammar_file path] reads a file and parses it into lists of key mappings and moves,
    exiting with specific errors for key mapping or move parsing issues. *)
let parse_grammar_file path =
  let key_mappings = ref [] in
  let move_sequences = ref [] in
  let ic = In_channel.create path in
  try
    In_channel.iter_lines ic ~f:(fun line ->
      if String.equal line "----------------------" |> not then
        match parse_key_mapping line with
        | Some km -> key_mappings := km :: !key_mappings
        | None ->
          let defined_keys = List.map !key_mappings ~f:(fun km -> km.key) in
          match parse_move_sequence ic line defined_keys with
          | Some mv -> move_sequences := mv :: !move_sequences
          | None -> failwith "Parsing error: Move sequence could not be parsed."
    );
    In_channel.close ic;
    (!key_mappings, !move_sequences)
  with
  | Sys_error err ->
    In_channel.close ic;
    failwith (Printf.sprintf "Error reading file: %s" err)
  | ex ->
    In_channel.close ic;
    raise ex
    

(** [show_key_mappings key_mappings] prints each key mapping in the list. *)
let show_key_mappings key_mappings =
  List.iter key_mappings ~f:(fun km ->
    printf "%s -> %s\n" km.key km.action
  )

(** [show_move_sequences moves] prints each move and its key combination in the list. *)
let show_move_sequences moves =
  List.iter moves ~f:(fun mv ->
    printf "%s move: %s\n" mv.name (String.concat ~sep:", " mv.key_combination)
  )

(** [validate_grammar] enforces general rules for the grammar:
    * Check that key_mappings is not empty
    * Check for duplicates within key_mappings and move_sequences
    * Ensure there are no unexpected special characters
    * Trim whitespace from each parsed element   
  *)
let validate_grammar key_mappings moves =
  let unique_keys = List.dedup_and_sort ~compare:String.compare (List.map key_mappings ~f:(fun km -> km.key)) in
  if List.length unique_keys <> List.length key_mappings then
    Error "Duplicate key mappings detected."
  else if List.exists moves ~f:(fun mv -> List.length mv.key_combination = 0 || String.is_empty mv.name) then
    Error "Invalid move format."
  else Ok ()
  

(* The function that combines the parsing, validation and tokenization process. *)

let process_grammar_file path =
  let key_mappings, move_sequences = parse_grammar_file path in
  match validate_grammar key_mappings move_sequences with
  | Ok () ->
      let tokenized_key_mappings = List.concat_map key_mappings ~f:tokenize_key_mapping in
      let tokenized_moves = List.concat_map move_sequences ~f:tokenize_move in
      (tokenized_key_mappings, tokenized_moves)
  | Error msg ->
      printf "Validation error: %s\n" msg;
      ([], [])

