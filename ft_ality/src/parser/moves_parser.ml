type move = { name : string; key_combination : string list }

exception ParseError of string

(** [parse_move_sequence ic line defined_actions] parses lines to create a [move] record:
    * The combo starts with [ and ends with ].
    * Each element within key_combination must be a defined key action. *)
let parse_move_sequence ic line defined_actions =
  if String.length line > 2 && line.[0] = '[' && String.contains line ']' then
    let closing_bracket_index = String.index line ']' in
    let combo_str = String.sub line 1 (closing_bracket_index - 1) in
    let key_combination =
      List.map String.trim (String.split_on_char ',' combo_str)
    in
    let remaining =
      String.sub line (closing_bracket_index + 1) (String.length line - closing_bracket_index - 1)
      |> String.trim
    in
    let name =
      if String.length remaining = 0 then
        try 
          let next_line = input_line ic in
          String.trim next_line
        with End_of_file -> ""
      else remaining
    in
    if List.for_all (fun action -> List.mem action defined_actions) key_combination then
      Some { name; key_combination }
    else
      raise (ParseError ("Undefined action in move combination [" ^ combo_str ^ "]"))
  else
    None
