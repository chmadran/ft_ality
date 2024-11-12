
type key_mapping = { key : string; action : string }
type move = { name : string; key_combination : string list }

val parse_grammar_file : string -> key_mapping list * move list
val show_key_mappings : key_mapping list -> unit
val show_move_sequences : move list -> unit
val process_grammar_file : string -> string list * string list

