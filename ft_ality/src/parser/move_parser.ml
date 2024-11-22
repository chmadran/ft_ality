open Base
open Types

let parse_move_sequence ic line defined_actions =
  if String.length line > 2 && Char.(line.[0] = '[') && String.contains line ']' then
    let closing_bracket_index = String.index_exn line ']' in
    let combo_str = String.sub line ~pos:1 ~len:(closing_bracket_index - 1) in
    let key_combination = String.split ~on:',' combo_str |> List.map ~f:String.strip in
    let remaining =
      String.sub line ~pos:(closing_bracket_index + 1) 
                  ~len:(String.length line - closing_bracket_index - 1)
      |> String.strip
    in
    let name =
      if String.is_empty remaining then
        match In_channel.input_line ic with
        | Some next_line -> String.strip next_line
        | None -> ""
      else remaining
    in
    if List.for_all key_combination ~f:(fun action -> List.mem defined_actions action ~equal:String.equal) then
      Some { name; key_combination }
    else
      raise (ParseError (Printf.sprintf "Undefined action in move combination [%s]" combo_str))
  else
    None
