type key_mapping = { key : string; action : string }
type move = { name : string; key_combination : string list }

exception ParseError of string
