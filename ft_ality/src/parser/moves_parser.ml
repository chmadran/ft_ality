type move = { name : string; key_combination : string list }

exception ParseError of string

(** [parse_move_sequence ic line defined_actions] parses lines to create a [move] record:
    * The combo starts with [ and ends with ].
    * Each element within key_combination must be a defined key action. *)
let parse_move_sequence ic line defined_actions =
  if Base.String.length line > 2 && Base.Char.(line.[0] = '[') && Base.String.contains line ']' then
    let closing_bracket_index = Base.String.index_exn line ']' in
    let combo_str = Base.String.sub line ~pos:1 ~len:(closing_bracket_index - 1) in
    let key_combination =
      Base.String.split ~on:',' combo_str |> Base.List.map ~f:Base.String.strip
    in
    let remaining =
      Base.String.sub line ~pos:(closing_bracket_index + 1)
                      ~len:(Base.String.length line - closing_bracket_index - 1)
      |> Base.String.strip
    in
    let name =
      if Base.String.is_empty remaining then
        match Stdio.In_channel.input_line ic with
        | Some next_line -> Base.String.strip next_line
        | None -> ""
      else remaining
    in
    if Base.List.for_all key_combination ~f:(fun action ->
           Base.List.mem defined_actions action ~equal:Base.String.equal
         )
    then
      Some { name; key_combination }
    else
      raise (ParseError (Printf.sprintf "Undefined action in move combination [%s]" combo_str))
  else
    None
