open Stdio

let get_keypress () =
  let termio = Unix.tcgetattr Unix.stdin in
  let () =
      Unix.tcsetattr Unix.stdin Unix.TCSADRAIN
          { termio with Unix.c_icanon = false ; c_echo = false } in
  let res = input_char stdin in
  Unix.tcsetattr Unix.stdin Unix.TCSADRAIN termio;
  res


(* let get_keypress () =
  (* Wait for a single character from the keyboard *)
  let ic = Unix.stdin in
  let buf = Bytes.create 1 in
  let _ = Unix.read ic buf 0 1 in
  Bytes.get buf 0 *)

let automaton_loop alphabet states transitions =
  List.iter (printf "%s\n") alphabet;
  List.iter (printf "%d\n") states;
  List.iter (fun (state, symbol, next_state) ->
    Printf.printf "State: %d, Symbol: %s, Next state: %d\n" state symbol next_state
  ) transitions;
(* 
  let rec loop current_state () =
    (* Add your loop logic here *)
    let _ = get_keypress () in
    (* printf "Start of loop:" ;
    printf "%c\n" key; *)
    loop current_state ()
  in
  loop 0 () *)
  
  (* let key = get_keypress () in
  printf "%c\n" key  *)