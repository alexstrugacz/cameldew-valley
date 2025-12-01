(** Game board - tile grid *)

type tile =
  | Soil of Crop.crop_instance option (* None = empty, Some = planted *)
  | Shop
  | Path

type board = tile array array

(* TODO: ask is this an ok amount of hardcoded info in the mode? just 12
   points. *)
let soil_points =
  [
    (415, 260);
    (555, 260);
    (695, 260);
    (835, 260);
    (415, 370);
    (555, 370);
    (695, 370);
    (835, 370);
    (415, 480);
    (555, 480);
    (695, 480);
    (835, 480);
  ]

let soil_side_length = 30

(** [is_soil x y] checks if ([x], [y]) is point in a soil block on the board *)
let is_soil x y =
  List.exists
    (fun (x', y') ->
      abs (x - x') <= soil_side_length && abs (y - y') <= soil_side_length)
    soil_points

(** [create_board width height] creates a new game board *)
let create_board width height =
  Array.init height (fun y ->
      Array.init width (fun x ->
          if 455 < x && x < 780 && -5 < y && y < 80 then Shop
          else if is_soil x y then Soil None
          else Path))

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
