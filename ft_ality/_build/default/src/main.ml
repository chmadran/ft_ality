open Base
open Stdio
open GrammarFile 

let check_file_input filename =
  match filename with
  (*case1 : get the second argument*)
  | [| _; filename |] ->
    (try
       if In_channel.with_file filename ~f:(fun _ -> true) then
         Some filename
       else (
         printf "Error: The file '%s' is not readable.\n" filename;
         None
       )
     with (*if try fails*)
     | Sys_error err ->
       printf "Error: %s\n" err;
       None)

  (*case2 : more than one arg detected*)
  | [| _; _; _ |] ->  
    printf "Error: Too many arguments provided. Please provide only one file as input.\n";
    None

  (*case3 : no args, only executable*)
  | _ -> 
    printf "Error: you need to provide one file as input.\n";
    None

let () =
  (* Assuming the file "grammar.txt" is passed as an argument *)
  match check_file_input (Sys.get_argv ()) with
  | Some filename ->
      (* If the file is valid, proceed with parsing *)
      printf "File '%s' is ready for parsing.\n" filename;

      (* Instantiate the grammarFile object with the valid filename *)
      let grammar = new grammarFile filename in

      (* Read and parse the grammar file *)
      grammar#read_grammar_file ();

      (* Show all key mappings *)
      printf "Key Mappings:\n";
      grammar#show_key_mappings ();

      (* Show all move sequences *)
      printf "\nMove Sequences:\n";
      grammar#show_move_sequences ()

  | None -> 
      (* Handle the case where no valid filename is provided *)
      printf "Error: Exiting program.\n";
      Caml.exit 1