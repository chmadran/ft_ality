module Key_mappings = Parser.Key_mappings
module Moves_parser = Parser.Moves_parser

type transition = { state : string list; key_pressed : string; next_state : string list }

let translate_key key alphabet =
  try
    let key_mapping = List.find (fun r -> r.Key_mappings.key = key) alphabet in
    key_mapping.Key_mappings.action
  with Not_found -> ""

(* Function to convert a string list to a string *)
let string_list_to_string lst =
  String.concat "; " lst

let print_transition tr =
  print_endline
    ("State: " ^ string_list_to_string tr.state ^ 
     ", Key: " ^ tr.key_pressed ^ 
     ", Next state: " ^ string_list_to_string tr.next_state)

let sdl_init () =
  try
    Sdl.init [`VIDEO];
    at_exit Sdl.quit
  with
  | e -> raise e

(* let sdl_loop () =
  match Sdlevent.poll_event with
  | None -> sdl_loop ()
  | Some  *)

let get_keypress () =
  flush stdout;
  let termio = Unix.tcgetattr Unix.stdin in
  let () = Unix.tcsetattr Unix.stdin Unix.TCSADRAIN { termio with Unix.c_icanon = false; c_echo = false } in
  let key_string =
    let res = input_char stdin in
    match res with
    | '~' -> "esc"
    | '\027' -> (
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
  Unix.tcsetattr Unix.stdin Unix.TCSADRAIN termio;
  key_string

let find_record (state: string list) (action: string) (transitions: transition list) =
  try
    List.find (fun r -> r.state = state && r.key_pressed = action) transitions
  with Not_found -> { state = [""]; key_pressed = ""; next_state = [""] }

let process_action current_state action transitions =
  let matching_record = find_record current_state action transitions in
  match matching_record with
  | { state = [""]; key_pressed = ""; next_state = [""] } -> (
      let matching_record = find_record ["Initial"] action transitions in
      match matching_record with
      | { state = [""]; key_pressed = ""; next_state = [""] } -> ["Initial"]
      | _ -> matching_record.next_state
    )
  | _ -> matching_record.next_state

let is_accepting_state next_state accepting_states =
  List.exists (fun move -> move.Moves_parser.key_combination = next_state) accepting_states

let print_move_names state accepting_states =
  let moves = List.filter (fun r -> r.Moves_parser.key_combination = state) accepting_states in
  match moves with
  | [] -> print_endline ""
  | _ -> List.iter (fun mv -> print_endline mv.Moves_parser.name) moves

let clear_screen () =
  print_endline "\027[2J"; (* ANSI escape code to clear screen *)
  flush stdout (* Ensure output is flushed *)

let automaton_loop alphabet accepting_states transitions =
  sdl_init ();
  Parser.show_key_mappings alphabet;
  Parser.show_move_sequences accepting_states;
  List.iter print_transition transitions;
  (* Stdio.printf *)

  let rec loop current_state () =
    let key = get_keypress () in
    match key with
    | "esc" -> exit 0
    | _ ->
      let action = translate_key key alphabet in
      match action with
      | "" -> loop current_state ()
      | _ ->
        clear_screen ();
        let next_state = process_action current_state action transitions in
        match next_state with
        | ["Initial"] -> (print_endline "\n[]\n"; loop next_state ())
        | _ -> (
            print_endline ("\n[" ^ string_list_to_string next_state ^ "]\n");
            print_move_names next_state accepting_states;
            loop next_state ()
          )
  in
  loop ["Initial"] ()
