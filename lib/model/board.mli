(** Game board - tile grid *)

(** Type representing different tiles on the game board *)
type tile =
  | Soil of Crop.crop_instance option
  | Shop  
  | Path  

(** Type representing the game board as a 2D array of tiles *)
type board = tile array array

(** [create_board width height] creates a new game board. *)
val create_board : int -> int -> board

(** [get_tile board x y] returns [Some tile] at position [(x, y)] if the
    position is within bounds, or [None] otherwise. *)
val get_tile : board -> int -> int -> tile option

(** [set_tile board x y tile] sets the tile at position [(x, y)] to [tile].
    Does nothing if the position is out of bounds. *)
val set_tile : board -> int -> int -> tile -> unit

(** [get_facing_tile board player] returns a tuple [(x, y, tile_opt)] where
    [(x, y)] is the position of the tile the player is facing, and [tile_opt]
    is [Some tile] if that position is valid, or [None] if out of bounds. *)
val get_facing_tile : board -> Player.player -> int * int * tile option

(** [board_iterate f board] applies the function [f] on every tile on the
    [board]. *)
val board_iterate : (int -> int -> tile -> unit) -> board -> unit