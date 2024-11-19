open Base
open Types

let is_valid_key key =
  let directions = ["up"; "down"; "left"; "right"] in
  (String.length key = 1 && Char.is_alpha key.[0]) || List.mem directions key ~equal:String.equal

let parse_key_mapping line =
  let parts = String.split ~on:' ' line in
  match parts with
  | [key; "->"; action]
    when is_valid_key key && String.for_all action ~f:Char.is_alpha ->
      Some { key = String.strip key; action = String.strip action }
  | _ -> None
