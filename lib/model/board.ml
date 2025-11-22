(** Game board - tile grid *)

type tile =
  | Soil of Crop.crop_instance option (* None = empty, Some = planted *)
  | Shop
  | Path

type board = tile array array

(* TODO: for now making everything soil, change later to use Path, Shop *)

(** [create_board width height] creates a new game board *)
let create_board width height =
  Array.init height (fun y -> Array.init width (fun x -> Soil None))

(** [get_tile board x y] gets tile at position (x, y)*)
let get_tile board x y =
  if y >= 0 && y < Array.length board && x >= 0 && x < Array.length board.(y)
  then Some board.(y).(x)
  else None

(** [set_tile board x y tile] sets tile at position (x, y)*)
let set_tile board x y tile =
  if y >= 0 && y < Array.length board && x >= 0 && x < Array.length board.(y)
  then board.(y).(x) <- tile

(** [get_facing_tile board player] gets the tile the player is facing *)
let get_facing_tile board player =
  let x, y =
    match player.Player.facing with
    | Player.North -> (player.x, player.y - 1)
    | Player.South -> (player.x, player.y + 1)
    | Player.West -> (player.x - 1, player.y)
    | Player.East -> (player.x + 1, player.y)
  in
  (x, y, get_tile board x y)
