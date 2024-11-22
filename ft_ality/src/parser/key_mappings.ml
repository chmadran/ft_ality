open Base

type key_mapping = { key : string; action : string }

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
  