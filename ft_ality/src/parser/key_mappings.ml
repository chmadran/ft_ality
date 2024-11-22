type key_mapping = { key : string; action : string }

(** [is_valid_key key] checks if a key is a single alphabetic character or a direction name. *)
let is_valid_key key =
  let directions = ["up"; "down"; "left"; "right"] in
  (String.length key = 1 && 
   (let c = key.[0] in ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z')))
  || List.mem key directions

(** [parse_key_mapping line] parses a line into a [key_mapping] record:
    * Checks that the line has exactly three elements: [key; "->"; action].
    * Validates that [key] is a valid key.
    * Both key and action must be alphabetic. *)
let parse_key_mapping line =
  let parts = String.split_on_char ' ' line in
  match parts with
  | [key; "->"; action]
    when is_valid_key key &&
         String.for_all (fun c -> ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z')) action ->
      Some
        {
          key = String.trim key;
          action = String.trim action;
        }
  | _ -> None
