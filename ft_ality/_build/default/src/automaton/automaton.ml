open Stdio

(* let rec get_input () : string =
  match Sdl.Event.poll_event () with
  | Some (Sdl.Event.KeyDown evt) -> Sdlkeycode.to_string evt.keycode
  | Some (Sdl.Event.Quit _) -> exit 0
  | _ -> get_input () *)

let get_keypress () =
  let termio = Unix.tcgetattr Unix.stdin in
  let () =
      Unix.tcsetattr Unix.stdin Unix.TCSADRAIN
          { termio with Unix.c_icanon = false ; c_echo = false } in
  let res = input_char stdin in
  Unix.tcsetattr Unix.stdin Unix.TCSANOW termio;
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

  (* Currently, if i try to access stdin to get keypresses, NOTHING happens in the program until the loop is over
    I don't understand why, so deactivates it if you work on your code *)
  (* let rec loop current_state () =
    match current_state with
    | 1 -> Caml.exit 0
    (* Add your loop logic here *)
    | 0 -> printf "Start of loop:\n" ;
    let key = get_keypress () in
    printf "%c\n" key;
    loop 1 ()
    | _ -> Caml.exit 1
  in
  loop 0 () *)