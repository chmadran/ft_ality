module Automaton = Automaton
module Parser = Parser

let create_transition current_state next_state =
  (* print_endline
    ("In create_transition " ^
     Automaton.string_list_to_string current_state ^ " -> " ^
     Automaton.string_list_to_string next_state); *)
  { Automaton.state = current_state; 
    key_pressed = List.hd (List.rev next_state); 
    next_state = next_state }

let create_move_transitions move =
  (* print_endline
    ("Creating transitions for: " ^ move.Parser.Moves_parser.name ^ " " ^
     Automaton.string_list_to_string move.Parser.Moves_parser.key_combination); *)
  let pairs =
    List.mapi
      (fun n _ ->
        let sublist_n = List.init n (fun i -> List.nth move.Parser.Moves_parser.key_combination i) in
        let sublist_n1 = List.init (n + 1) (fun i -> List.nth move.Parser.Moves_parser.key_combination i) in
        (sublist_n, sublist_n1))
      move.Parser.Moves_parser.key_combination
  in
  let transitions = 
    List.map (fun (a, b) -> create_transition a b) (List.tl pairs)
  in
  List.append transitions
    [create_transition ["Initial"] [List.hd move.Parser.Moves_parser.key_combination]]

let remove_duplicates transitions =
  let rec remove_seen seen = function
    | [] -> List.rev seen
    | transition :: rest ->
        if List.exists 
             (fun t ->
               t.Automaton.state = transition.Automaton.state &&
               t.Automaton.key_pressed = transition.Automaton.key_pressed &&
               t.Automaton.next_state = transition.Automaton.next_state)
             seen 
        then remove_seen seen rest
        else remove_seen (transition :: seen) rest
  in
  remove_seen [] transitions

let create_transitions move_sequences =
  let transitions = List.flatten (List.map create_move_transitions move_sequences) in
  (* print_endline "Generated transitions:";
  print_endline ("Len before: " ^ string_of_int (List.length transitions));
  List.iter Automaton.print_transition transitions; *)

  let transitions_no_duplicates = remove_duplicates transitions in

  (* print_endline "After removing duplicates:";
  print_endline ("Len after: " ^ string_of_int (List.length transitions_no_duplicates));
  List.iter Automaton.print_transition transitions_no_duplicates; *)

  transitions_no_duplicates
