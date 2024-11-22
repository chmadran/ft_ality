module Key_mappings : sig
    type key_mapping = { key : string; action : string }
  end

module Moves_parser : sig
    type move = { name : string; key_combination : string list }
  end

val process_grammar_file : string -> Key_mappings.key_mapping list * Moves_parser.move list
val show_key_mappings : Key_mappings.key_mapping list -> unit
val show_move_sequences : Moves_parser.move list -> unit