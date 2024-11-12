
open Base
open Stdio

type key_mapping = { key : string; action : string }
type move = { name : string; key_combination : string list }

(** [parse_key_mapping line] parses a line into a [key_mapping] record, if it matches the expected format. *)
let parse_key_mapping line =
  let parts = String.split line ~on:' ' in
  match parts with
  | [key; "->"; action] -> Some { key = String.strip key; action = String.strip action }
  | _ -> None

(** [parse_move_sequence ic line] parses lines to create a [move] record.
    Expects a line starting with "[" for key combinations and a line with a move name. *)
let parse_move_sequence ic line =
  if String.length line > 2 && Char.(line.[0] = '[') then
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
    Some { name; key_combination }
  else
    None
    
(** [tokenize_key_mapping km] converts a [key_mapping] record into a list of tokens *)
let tokenize_key_mapping (km: key_mapping) : string list =
  [km.key; km.action]

(** [tokenize_move mv] converts a [move] record into a list of tokens *)
let tokenize_move (mv: move) : string list =
  mv.key_combination @ [mv.name]
    

(** [parse_grammar_file path] reads a file and parses it into lists of key mappings and moves. *)
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
          match parse_move_sequence ic line with
          | Some mv -> move_sequences := mv :: !move_sequences
          | None -> ()
    );
    In_channel.close ic;
    (!key_mappings, !move_sequences)
  with Sys_error err ->
    printf "Error reading file: %s\n" err;
    In_channel.close ic;
    ([], [])


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


(* The function that combines the parsing and tokenization. *)
let process_grammar_file path =
  let key_mappings, move_sequences = parse_grammar_file path in
  let tokenized_key_mappings = List.concat_map key_mappings ~f:tokenize_key_mapping in
  let tokenized_moves = List.concat_map move_sequences ~f:tokenize_move in
  (tokenized_key_mappings, tokenized_moves)