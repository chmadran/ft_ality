(* grammarFile.mli *)
class keyMapping : string -> string -> object
    method mapKeyToAction : unit -> unit
  end
  
  class move : string -> string list -> object
    method apply : unit -> unit
  end
  
  class grammarFile : string -> object
    method read_grammar_file : unit -> unit
    method show_key_mappings : unit -> unit
    method show_move_sequences : unit -> unit
  end
  