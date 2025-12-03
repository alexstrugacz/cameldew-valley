open OUnit2
module B = Model.Board
module P = Model.Player

(** [board_dims] checks that create_board allocates a grid with the correct
    requested width and height. *)
let board_dims _ =
  let b = B.create_board 10 5 in
  assert_equal 5 (Array.length b);
  assert_equal 10 (Array.length b.(0))

(** [innout_of_bounds_tile] checks that get_tile returns Some for in-bounds
    coordinates and None for out-of-bounds. *)
let innout_of_bounds_tile _ =
  let b = B.create_board 3 3 in
  (match B.get_tile b 1 1 with
  | Some B.Path -> ()
  | _ -> assert_failure "expected Path at (1,1)");
  assert_equal None (B.get_tile b (-1) 0);
  assert_equal None (B.get_tile b 0 3)

(** [test_set_tile_updates_board] checks that set_tile actually replaces the
    tile at the given coordinates. *)
let test_set_tile_updates_board _ =
  let b = B.create_board 3 3 in
  B.set_tile b 1 1 B.Shop;
  match B.get_tile b 1 1 with
  | Some B.Shop -> ()
  | _ -> assert_failure "expected Shop at (1,1) after set_tile"

(** [shop_region] checks that creating a large board uses the special
    shop-rectangle and marks tiles there as Shop. *)
let shop_region _ =
  let b = B.create_board 800 100 in
  match B.get_tile b 500 10 with
  | Some B.Shop -> ()
  | _ -> assert_failure "Expected a Shop tile inside shop rectangle"

(** [get_facing_tile_(DIRECTION)] checks that get_facing_tile returns the tile
    directly in front of the player based on their facing. *)
let get_facing_tile_SOUTH _ =
  let b = B.create_board 3 3 in
  let p = P.create_player 1 1 0 in
  let fx, fy, tile_opt = B.get_facing_tile b p in
  assert_equal 1 fx;
  assert_equal 2 fy;
  match tile_opt with
  | Some B.Path -> ()
  | _ -> assert_failure "Expected Soil None in front of player"

let get_facing_tile_EAST _ =
  let b = B.create_board 3 3 in
  let p0 = P.create_player 1 1 0 in
  let p = { p0 with facing = P.East } in
  let fx, fy, tile_opt = B.get_facing_tile b p in
  assert_equal 2 fx;
  assert_equal 1 fy;
  match tile_opt with
  | Some B.Path -> ()
  | _ -> assert_failure "Expected Soil None"

let get_facing_tile_NORTH _ =
  let b = B.create_board 3 3 in
  let p0 = P.create_player 1 1 0 in
  let p = { p0 with facing = P.North } in
  let fx, fy, tile_opt = B.get_facing_tile b p in
  assert_equal 1 fx;
  assert_equal 0 fy;
  match tile_opt with
  | Some B.Path -> ()
  | _ -> assert_failure "Expected Soil None"

let get_facing_tile_WEST _ =
  let b = B.create_board 3 3 in
  let p0 = P.create_player 1 1 0 in
  let p = { p0 with facing = P.West } in
  let fx, fy, tile_opt = B.get_facing_tile b p in
  assert_equal 0 fx;
  assert_equal 1 fy;
  match tile_opt with
  | Some B.Path -> ()
  | _ -> assert_failure "Expected Soil None"

let suite =
  "board tests"
  >::: [
         "create_board_dimensions" >:: board_dims;
         "innout_of_bounds_tile" >:: innout_of_bounds_tile;
         "set_tile_updates_board" >:: test_set_tile_updates_board;
         "shop_region" >:: shop_region;
         "facing_south" >:: get_facing_tile_SOUTH;
         "facing_east" >:: get_facing_tile_EAST;
         "facing_north" >:: get_facing_tile_NORTH;
         "facing_west" >:: get_facing_tile_WEST;
       ]

let () = run_test_tt_main suite
