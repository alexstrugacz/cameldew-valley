open OUnit2
module P = Model.Player
module Crop = Model.Crop

(** [create_player] checks that a new player: - starts at the given (x,y) -
    faces South uses the given starting coins - has 5 inventory slots - has
    selected_slot = 0. *)
let create_player _ =
  let p = P.create_player 10 20 50 in
  let x, y = P.get_current_tile p in
  assert_equal 10 x;
  assert_equal 20 y;
  assert_equal P.South p.facing;
  assert_equal 50 p.coins;
  assert_equal 5 (Array.length p.inventory);
  assert_equal 0 p.selected_slot

(** [player_movement] checks that moving within bounds: - changes the tile by 4
    units in the direction of movement - updates the facing direction. *)
let player_movement _ =
  let p = P.create_player 10 10 0 in
  let board_w, board_h = (100, 100) in

  let p1 = P.move_player p P.North board_w board_h in
  let x1, y1 = P.get_current_tile p1 in
  assert_equal 10 x1;
  assert_equal 6 y1;
  assert_equal P.North p1.facing;

  let p2 = P.move_player p1 P.West board_w board_h in
  let x2, y2 = P.get_current_tile p2 in
  assert_equal 6 x2;
  assert_equal 6 y2;
  assert_equal P.West p2.facing;

  let p3 = P.move_player p2 P.South board_w board_h in
  let x3, y3 = P.get_current_tile p3 in
  assert_equal 6 x3;
  assert_equal 10 y3;
  assert_equal P.South p3.facing

(** [can't_move_in_invalid_spots] attempting to move into the forbidden shop
    region keeps the player's position unchanged, but still updates the facing
    direction. *)
let can't_move_in_invalid_spots _ =
  let p = P.create_player 459 10 0 in
  let x0, y0 = P.get_current_tile p in
  let board_w, board_h = (1280, 720) in
  let p' = P.move_player p P.East board_w board_h in
  let x1, y1 = P.get_current_tile p' in
  assert_equal x0 x1;
  assert_equal y0 y1;
  assert_equal P.East p'.facing

(** [crop_slot_fixed_mapping] checks that each crop kind maps to the intended
    fixed inventory index. *)
let crop_slot_fixed_mapping _ =
  assert_equal 0 (P.slot_for_crop Crop.Wheat);
  assert_equal 1 (P.slot_for_crop Crop.Strawberry);
  assert_equal 2 (P.slot_for_crop Crop.Grape);
  assert_equal 3 (P.slot_for_crop Crop.Tomato);
  assert_equal 4 (P.slot_for_crop Crop.Pumpkin)

(** [add_and_remove_seeds] checks the behavior of add_seeds / remove_seed
    WITHOUT inspecting internal inventory slots: - add_seeds returns Some player
    \- remove_seed returns Some (player, kind) while seeds remain - after enough
    removals, remove_seed returns None. *)
let add_and_remove_seeds _ =
  let base = P.create_player 0 0 0 in
  let idx = P.slot_for_crop Crop.Wheat in

  (* add 2 wheat seeds *)
  let p1 =
    match P.add_seeds base Crop.Wheat 2 with
    | None -> assert_failure "add_seeds returned None"
    | Some p -> p
  in

  (* remove first seed *)
  let p2, kind1 =
    match P.remove_seed p1 idx with
    | None -> assert_failure "remove_seed returned None (first)"
    | Some res -> res
  in
  assert_equal Crop.Wheat kind1;

  (* remove second seed *)
  let p3, kind2 =
    match P.remove_seed p2 idx with
    | None -> assert_failure "remove_seed returned None (second)"
    | Some res -> res
  in
  assert_equal Crop.Wheat kind2;

  (* now the slot should be empty n removing again wld return None *)
  let r3 = P.remove_seed p3 idx in
  assert_equal None r3

(** [remove_seed_invalid_slot] checks that trying to remove from an invalid slot
    index returns None. *)
let remove_seed_invalid_slot _ =
  let p = P.create_player 0 0 0 in
  assert_equal None (P.remove_seed p 999)

(** [harvest_and_sell] checks that harvest_and_sell increases coins exactly by
    the crop's sell_price. *)
let harvest_and_sell _ =
  let p = P.create_player 0 0 5 in
  let c = Crop.create_crop Crop.Tomato in
  let p' = P.harvest_and_sell p c in
  assert_equal (5 + c.Crop.stats.sell_price) p'.P.coins

(** [get_current_tile] checks that get_current_tile just returns (x,y). *)
let get_current_tile _ =
  let p = P.create_player 7 9 0 in
  assert_equal (7, 9) (P.get_current_tile p)

let suite =
  "player tests"
  >::: [
         "create_player" >:: create_player;
         "player_movement" >:: player_movement;
         "can't_move_in_invalid_spots" >:: can't_move_in_invalid_spots;
         "crop_slot_fixed_mapping" >:: crop_slot_fixed_mapping;
         "add_and_remove_seeds" >:: add_and_remove_seeds;
         "remove_seed_invalid_slot" >:: remove_seed_invalid_slot;
         "harvest_and_sell" >:: harvest_and_sell;
         "get_current_tile" >:: get_current_tile;
       ]

let () = run_test_tt_main suite
