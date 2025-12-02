(** Player state and inventory management *)

(** Type representing cardinal directions *)
type direction =
  | North
  | South
  | East
  | West

type inventory_slot = {
  seed_type : Crop.crop_kind option;
  count : int;
}
(** Type representing a single inventory slot for seeds *)

type player = {
  x : int;
  y : int;
  facing : direction;
  coins : int;
  inventory : inventory_slot array;
  selected_slot : int;
}
(** Type representing the player's state *)

val create_player : int -> int -> int -> player
(** [create_player x y starting_coins] creates a new player at position [(x, y)]
    with the specified starting amount of coins. The player initially faces
    South and has an empty inventory. *)

val move_player : player -> direction -> int -> int -> player
(** [move_player player dir board_width board_height] moves the player in the
    specified direction, updating their position and facing direction. *)

val slot_for_crop : Crop.crop_kind -> int
(** [slot_for_crop kind] returns the fixed inventory slot index (0-4) for the
    given crop kind. Each crop type has a dedicated slot. *)

val add_seeds : player -> Crop.crop_kind -> int -> player option
(** [add_seeds player kind count] adds [count] seeds of the given [kind] to the
    player's inventory in the appropriate slot. Returns [Some player] with
    updated inventory. *)

val remove_seed : player -> int -> (player * Crop.crop_kind) option
(** [remove_seed player slot_idx] removes one seed from the inventory slot at
    [slot_idx]. Returns [Some (player, kind)] with the updated player and the
    crop kind that was removed, or [None] if the slot is invalid or empty. *)

val harvest_and_sell : player -> Crop.crop_instance -> player
(** [harvest_and_sell player crop] immediately sells the harvested crop and adds
    the sell price to the player's coins. *)

val get_current_tile : player -> int * int
(** [get_current_tile player] returns the player's current position as a tuple
    [(x, y)]. *)

val remove_coins : player -> int -> player
(** [remove_coins player num_coins] returns player with [num_coins] subtracted
    from the current number of coins *)