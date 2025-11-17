(** [handle_actions board_width board_height p actions] returns a new player representing all [actions] applied to player [p] on a board with [board_height] and [board_width]] *)
val handle_actions : int -> int -> Model.Player.player -> Input_handler.action list -> Model.Player.player

