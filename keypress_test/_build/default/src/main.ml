let get_keypress () =
  let termio = Unix.tcgetattr Unix.stdin in
  let () =
      Unix.tcsetattr Unix.stdin Unix.TCSADRAIN
          { termio with Unix.c_icanon = false ; c_echo = false } in
  let res = Stdio.In_channel.input_char Stdio.In_channel.stdin in
  Unix.tcsetattr Unix.stdin Unix.TCSANOW termio;
  res


let get = function
| Some v -> v
| None -> raise (Invalid_argument "option is None")

let () =
  Stdio.printf "Hi\n";
  let key = get_keypress () in
  Stdio.printf "Here\n";
  Stdio.printf "%c " (get key)