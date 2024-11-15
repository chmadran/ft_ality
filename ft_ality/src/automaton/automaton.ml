open Stdio
open Parser

type transition = { state : string list; key_pressed : string; next_state : string list }

let translate_key key alphabet =
  try
    let key_mapping = (List.find (fun r -> r.key = key) alphabet) in
    let action = key_mapping.action in
    action
  with Not_found -> ""

(* Function to convert a string list to a string *)
let string_list_to_string lst =
	String.concat "; " lst

let print_transition tr =
  printf "State: %s, Key: %s, Next state: %s\n" (string_list_to_string tr.state) tr.key_pressed (string_list_to_string tr.next_state)

let get_keypress () =
  Stdio.Out_channel.flush Stdio.stdout;
  let termio = Unix.tcgetattr Unix.stdin in
  let () = Unix.tcsetattr Unix.stdin Unix.TCSANOW { termio with Unix.c_icanon = false ; c_echo = false } in
  let key_string =
    let res = input_char stdin in
    match res with
    (* Cheat to esacpe in one keypress *)
    | '~' -> "esc"
    | '\027' -> (
      (* Need to find a way to escape on the first press of ESC, because you can cheat by typing ESC then [ and stay in the program*)
      let res = input_char stdin in
      match res with
      | '[' -> (
        let res = input_char stdin in
        match res with
        | 'A' -> "up"
        | 'B' -> "down"
        | 'C' -> "right"
        | 'D' -> "left"
        | _ -> ""
      )
      | _ -> "esc"
    )
    | _ -> String.make 1 res
  in 
  Unix.tcsetattr Unix.stdin Unix.TCSANOW termio;
  key_string

let find_record (state: string list) (action: string) (transitions: transition list) =
  try
    List.find (fun r -> r.state = state && r.key_pressed = action) transitions
  with Not_found -> {state = [""]; key_pressed = ""; next_state = [""]}

let process_action current_state action transitions =
  let matching_record = find_record current_state action transitions in
  match matching_record with
  | {state = [""]; key_pressed = ""; next_state = [""]} -> ["Initial"]
  | _ -> let next_state = matching_record.next_state in
  printf "Found Next State: %s\n" (string_list_to_string next_state);
  next_state

let is_accepting_state next_state accepting_states =
  List.exists (fun move -> move.key_combination = next_state) accepting_states

let print_move_names state accepting_states = 
  let moves = List.filter (fun r -> r.key_combination = state) accepting_states in
  List.iter (fun mv -> printf "%s\n" mv.name) moves

let automaton_loop alphabet accepting_states transitions =
  Parser.show_key_mappings alphabet;
  Parser.show_move_sequences accepting_states;
  List.iter print_transition transitions;

  let rec loop current_state () =
    printf "\nCurrent_state: %s\n" (string_list_to_string current_state);
    let key = get_keypress () in
    match key with
    | "esc" -> Stdlib.exit 0
    | _ ->
      let action = translate_key key alphabet in
      printf "Key pressed: %s, Action: %s\n" key action;
      let next_state = process_action current_state action transitions in
      printf "Next_state: %s\n" (string_list_to_string next_state);
      if is_accepting_state next_state accepting_states then
        printf "%s is an accepting state\n" (string_list_to_string next_state);
        print_move_names next_state accepting_states;
      loop next_state ()
  in
  loop ["Initial"] ()