(* open Stdio *)
open Automaton
open Parser

let create_transition current_state next_state = 
  Stdio.printf "In create_transition %s -> %s\n" (Automaton.string_list_to_string current_state) (Automaton.string_list_to_string next_state);
  let transition = { state = current_state; key_pressed = List.hd (List.rev next_state); next_state = next_state } in
  Automaton.print_transition transition;
  transition

let create_move_transitions move = 
  Stdio.printf "Creating transitions for: %s %s\n" move.name (Automaton.string_list_to_string move.key_combination);
  let pairs = List.mapi (fun n _ ->
    let sublist_n = List.init n (fun i -> List.nth move.key_combination i) in
    let sublist_n1 = List.init (n + 1) (fun i -> List.nth move.key_combination i) in
    (sublist_n, sublist_n1)
  ) move.key_combination in
  (* List.iter (fun (a, b) -> Printf.printf "First: [%s], Second: [%s]\n" (String.concat "; " a) (String.concat "; " b)) (List.tl pairs); *)
  let transitions = List.map (fun (a, b) -> create_transition a b) (List.tl pairs) in
  List.append transitions [(create_transition ["Initial"] ([List.hd move.key_combination]))]

(* TO DO *)
let remove_duplicates transitions = 
  transitions

let create_transitions move_sequences = 
  Stdio.printf "In create_transitions\n";
  Parser.show_move_sequences move_sequences;
  Automaton.print_transition (create_transition ["Initial"] ["Punch"]);

  let transitions = List.flatten (List.map create_move_transitions move_sequences) in
  Stdio.printf "Generated transitions:\n";
  List.iter Automaton.print_transition transitions;
  remove_duplicates transitions