open Base
open Stdio
open Types
open Key_mapping_parser
open Move_parser


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
