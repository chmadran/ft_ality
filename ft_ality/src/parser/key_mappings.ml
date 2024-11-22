type key_mapping = { key : string; action : string }

(** [is_valid_key key] checks if a key is a single alphabetic character or a direction name. *)
let is_valid_key key =
  let directions = ["up"; "down"; "left"; "right"] in
  (Base.String.length key = 1 && Base.Char.is_alpha key.[0])
  || Base.List.mem directions key ~equal:Base.String.equal

(** [parse_key_mapping line] parses a line into a [key_mapping] record:
    * Checks that the line has exactly three elements: [key; "->"; action].
    * Validates that [key] is a valid key.
    * Both key and action must be alphabetic. *)
let parse_key_mapping line =
  let parts = Base.String.split ~on:' ' line in
  match parts with
  | [key; "->"; action]
    when is_valid_key key && Base.String.for_all action ~f:Base.Char.is_alpha ->
      Some
        {
          key = Base.String.strip key;
          action = Base.String.strip action;
        }
  | _ -> None
