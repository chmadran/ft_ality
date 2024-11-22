(** [validate_key_mappings key_mappings] ensures no duplicate keys or actions exist. *)
let validate_key_mappings key_mappings =
  let keys = Base.List.map key_mappings ~f:(fun km -> km.Key_mappings.key) in
  let actions = Base.List.map key_mappings ~f:(fun km -> km.Key_mappings.action) in
  let duplicate_keys = Base.List.contains_dup keys ~compare:Base.String.compare in
  let duplicate_actions = Base.List.contains_dup actions ~compare:Base.String.compare in
  if duplicate_keys then
    Base.Result.Error "Duplicate keys found in key mappings."
  else if duplicate_actions then
    Base.Result.Error "Duplicate actions found in key mappings."
  else
    Base.Result.Ok ()

(** [validate_moves moves] ensures move names are unique. *)
let validate_moves moves =
  let move_names = Base.List.map moves ~f:(fun mv -> mv.Moves_parser.name) in
  if Base.List.contains_dup move_names ~compare:Base.String.compare then
    Base.Result.Error "Duplicate move names found."
  else
    Base.Result.Ok ()

(** [validate_grammar key_mappings moves] performs all validations on parsed data. *)
let validate_grammar key_mappings moves =
  match validate_key_mappings key_mappings with
  | Base.Result.Error msg -> Base.Result.Error msg
  | Base.Result.Ok () -> (
      match validate_moves moves with
      | Base.Result.Error msg -> Base.Result.Error msg
      | Base.Result.Ok () -> Base.Result.Ok ()
    )
