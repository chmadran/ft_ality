class move (name : string) (key_combination : string list) =
  object
    val name : string = name
    val key_combination : string list = key_combination

    (* Applies the move. For simplicity, it prints a message when the move is applied. *)
    method apply () =
      Printf.printf "Executing %s move: %s\n" name (String.concat ", " key_combination)
  end


class keyMapping (key : string) (action : string) =
  object
    val key : string = key
    val action : string = action

    (* Maps key to action, here it's simply stored in the object *)
    method mapKeyToAction () =
      Printf.printf "%s -> %s\n" key action
  end


class grammarFile (path : string) =
  object (self)
    val path : string = path  (* stores the grammar file *)
    val mutable key_mappings : keyMapping list = [] (*  list of keyMapping objects, representing mappings between keys like shift and actions like Punch  *)
    val mutable move_sequences : move list = []  (*  list of move objects, representing sequences of actions triggered by specific key combinations like [Punch, Forward] for "Front Punch" *)

    (* Creates the key mappings objects*)
    method private parse_key_mapping line =
      let parts = String.split_on_char ' ' line in
      match parts with
      | [key; "->"; action] ->
          let key_trimmed = String.trim key in
          let action_trimmed = String.trim action in
          Some (new keyMapping key_trimmed action_trimmed)
      | _ -> None

    (* Creates sequences, a line starting with a "[" indicates a move sequence *)
    (* @@ TODO: improve this? not sure how far the parsing needs to go*)
    method private parse_move_sequence ic line =
      if String.length line > 2 && line.[0] = '[' then
        (* Step 1: Extract combo_str and combo list *)
        let closing_bracket_index = String.index line ']' in
        let combo_str = String.sub line 1 (closing_bracket_index - 1) in
        Printf.printf "Combo string extracted: %s\n" combo_str;  (* Debug: combo_str *)
        let combo = String.split_on_char ',' combo_str |> List.map String.trim in
    
        (* Step 2: Extract remaining part after the combo *)
        let remaining = String.sub line (closing_bracket_index + 1) (String.length line - closing_bracket_index - 1) |> String.trim in
        Printf.printf "Remaining string after combo: '%s'\n" remaining;  (* Debug: remaining *)
    
        (* Check if remaining is empty, and if so, try to read the next line for the move name *)
        let name =
          if remaining = "" then
            try
              let next_line = input_line ic in  (* Read the next line if remaining is empty *)
              Printf.printf "Next line for move name: '%s'\n" next_line;
              let trimmed_next_line = String.trim next_line in
              if String.contains trimmed_next_line '!' then
                let excl_index = String.index trimmed_next_line '!' in
                String.sub trimmed_next_line 0 excl_index |> String.trim
              else
                trimmed_next_line
            with End_of_file -> ""
          else
            (* Capture the name by looking for "!!" and getting the part before it *)
            if String.contains remaining '!' then
              let excl_index = String.index remaining '!' in
              String.sub remaining 0 excl_index |> String.trim
            else
              remaining
        in
        Printf.printf "Final name used for move: '%s'\n" name;  (* Debug: Final name *)
        
        Some (new move name combo)
      else
        None    
      
    (* Read and parse the file to populate key mappings and move sequences *)
    method read_grammar_file () =
      try
        let ic = open_in path in
        let rec read_lines () =
          try
            let line = input_line ic in
            if line = "----------------------" then
              ()
            else
              begin
                (* If the line matches a key mapping, it adds the resulting keyMapping object to key_mappings. If the line matches a key mapping, it adds the resulting keyMapping object to key_mappings.*)                 
                match self#parse_key_mapping line with
                | Some mapping -> key_mappings <- mapping :: key_mappings
                | None ->
                  (*  If the line matches a move sequence, it adds the resulting move object to move_sequences. *)
                  match self#parse_move_sequence ic line with  (* Pass ic here *)
                  | Some seq -> move_sequences <- seq :: move_sequences
                  | None -> ()
              end;
            read_lines ()
          with End_of_file -> close_in ic
        in
        read_lines ()
      with Sys_error err ->
        Printf.printf "Error reading file: %s\n" err;
        ()
    

    (* Display all key mappings *)
    method show_key_mappings () =
      List.iter (fun km -> km#mapKeyToAction ()) key_mappings

    (* Display all move sequences *)
    method show_move_sequences () =
      List.iter (fun mv -> mv#apply ()) move_sequences
  end
