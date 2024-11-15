open Stdio

type transition = { state : string list; key_pressed : string; next_state : string list }

(* Function to convert a string list to a string *)
let string_list_to_string lst =
	"[" ^ (String.concat "; " lst) ^ "]"

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

let find_records (state: string list) (key: string) (transitions: transition list)=
  List.filter (fun r -> r.state = state && r.key_pressed = key) transitions

let process_key current_state key transitions =
  (* let matching_record = find_records current_state key transitions in
  match matching_record with
  | [] -> ["Initial"]
  | _ -> (List.hd matching_record).next_state *)
  [(string_list_to_string current_state);key; List.hd((List.hd transitions).state)]

(* let is_accepting_states next_state accepting_states =
  List.exists (fun move -> move.key_combination = next_state) accepting_states *)

let automaton_loop alphabet accepting_states transitions =
  Parser.show_key_mappings alphabet;
  Parser.show_move_sequences accepting_states;
  List.iter print_transition transitions;

  let rec loop current_state () =
    printf "current_state:%s\n" (string_list_to_string current_state);
    let key = get_keypress () in
    match key with
    | "esc" -> Stdlib.exit 0
    | _ ->
      let next_state = process_key current_state key transitions in
      printf "Key pressed: %s, next_state: %s\n" key (string_list_to_string next_state);
      (* if is_accepting_states next_state accepting_states then
        printf "Accepting state: %s\n" (string_list_to_string current_state)
      else
        print "Non accepting state\n" *)
      loop next_state ()
  in
  loop ["Initial"] ()