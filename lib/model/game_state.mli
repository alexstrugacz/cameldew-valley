(** [phase] represents the current phase of the game. This can be seen as the "state". *)
type phase =
  | Playing
  | NotPlaying
  | Paused

(** [game_state] stores game state data for the player, board, and the current phase they are in. *)
type game_state = {
  phase : phase;
  player : Player.player;
  initial_player : Player.player;
  board_width : int;
  board_height : int;
  board : Board.board;
  elapsed_time : float;
}

(** [init w h p game_state] initializes the game's state [game_state] with  width [w], height [h], and player [p]. *)
val init : int -> int -> Player.player -> game_state

(** [start game_state] given a [game_state] changes the phase to [Playing]. *)
val start : game_state -> game_state

(** [stop game_state] given a [game_state] changes the phase to [NotPlaying]. *)
val stop : game_state -> game_state

(** [toggle_pause game_state] given a [game_state] changes the phase to [Paused]. *)
val toggle_pause : game_state -> game_state