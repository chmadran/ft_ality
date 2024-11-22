open Base
open Types

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

let validate_moves moves =
  let move_names = List.map moves ~f:(fun mv -> mv.name) in
  if List.contains_dup move_names ~compare:String.compare then
    Error "Duplicate move names found."
  else
    Ok ()

let validate_grammar key_mappings moves =
  match validate_key_mappings key_mappings with
  | Error msg -> Error msg
  | Ok () -> (
      match validate_moves moves with
      | Error msg -> Error msg
      | Ok () -> Ok ()
    )