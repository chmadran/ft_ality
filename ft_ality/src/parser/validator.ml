(** [validate_key_mappings key_mappings] ensures no duplicate keys or actions exist. *)
let validate_key_mappings key_mappings =
  let keys = List.map (fun km -> km.Key_mappings.key) key_mappings in
  let actions = List.map (fun km -> km.Key_mappings.action) key_mappings in
  let has_duplicates lst =
    let rec aux seen = function
      | [] -> false
      | x :: xs -> if List.mem x seen then true else aux (x :: seen) xs
    in
    aux [] lst
  in
  if has_duplicates keys then
    Error "Duplicate keys found in key mappings."
  else if has_duplicates actions then
    Error "Duplicate actions found in key mappings."
  else
    Ok ()

(** [validate_moves moves] ensures move names are unique. *)
let validate_moves moves =
  let move_names = List.map (fun mv -> mv.Moves_parser.name) moves in
  let has_duplicates lst =
    let rec aux seen = function
      | [] -> false
      | x :: xs -> if List.mem x seen then true else aux (x :: seen) xs
    in
    aux [] lst
  in
  if has_duplicates move_names then
    Error "Duplicate move names found."
  else
    Ok ()

(** [validate_grammar key_mappings moves] performs all validations on parsed data. *)
let validate_grammar key_mappings moves =
  match validate_key_mappings key_mappings with
  | Error msg -> Error msg
  | Ok () -> (
      match validate_moves moves with
      | Error msg -> Error msg
      | Ok () -> Ok ()
    )
