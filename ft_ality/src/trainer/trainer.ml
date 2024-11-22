module Automaton = Automaton
module Parser = Parser


let create_transition current_state next_state = 
  Printf.printf "In create_transition %s -> %s\n" (Automaton.string_list_to_string current_state) (Automaton.string_list_to_string next_state);
  let transition = { Automaton.state = current_state; key_pressed = List.hd (List.rev next_state); next_state = next_state } in
  (* Automaton.print_transition transition; *)
  transition

let create_move_transitions move = 
  Printf.printf "Creating transitions for: %s %s\n" move.Parser.Moves_parser.name (Automaton.string_list_to_string move.Parser.Moves_parser.key_combination);
  let pairs = List.mapi (fun n _ ->
    let sublist_n = List.init n (fun i -> List.nth move.Parser.Moves_parser.key_combination i) in
    let sublist_n1 = List.init (n + 1) (fun i -> List.nth move.Parser.Moves_parser.key_combination i) in
    (sublist_n, sublist_n1)
  ) move.Parser.Moves_parser.key_combination in
  (* List.iter (fun (a, b) -> Printf.printf "First: [%s], Second: [%s]\n" (String.concat "; " a) (String.concat "; " b)) (List.tl pairs); *)
  let transitions = List.map (fun (a, b) -> create_transition a b) (List.tl pairs) in
  List.append transitions [(create_transition ["Initial"] ([List.hd move.Parser.Moves_parser.key_combination]))]

let remove_duplicates transitions =
  let rec remove_seen seen = function
    | [] -> List.rev seen
    | transition :: rest ->

        if List.exists (fun t -> t.Automaton.state = transition.Automaton.state &&
                                  t.Automaton.key_pressed = transition.Automaton.key_pressed &&
                                  t.Automaton.next_state = transition.Automaton.next_state) seen then
          remove_seen seen rest           
        else
          remove_seen (transition :: seen) rest  
  in
  remove_seen [] transitions  


  let create_transitions move_sequences = 
  
    let transitions = List.flatten (List.map create_move_transitions move_sequences) in
    Printf.printf "Generated transitions:\n";
    Printf.printf "Len before: %d\n" (List.length transitions);
    List.iter Automaton.print_transition transitions;
    
    let transitions_no_duplicates = remove_duplicates transitions in
    
    Printf.printf "After removing duplicates:\n";
    Printf.printf "Len after: %d\n" (List.length transitions_no_duplicates);
    List.iter Automaton.print_transition transitions_no_duplicates;
    transitions_no_duplicates
  