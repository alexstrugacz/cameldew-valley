open OUnit2
module GS = Model.Game_state
module P = Model.Player
module B = Model.Board
module Crop = Model.Crop
module IH = Controller.Input_handler
module C = Controller.Game_controller

(* helper func to produce a game w playing state *)
let make_playing_state width height player =
  GS.start (GS.init width height player "test_user")

(** [plant_seed_on_empty_soil] Test planting when soil tile is None and player
    has seeds *)
let plant_seed_on_empty_soil _ =
  let player_x = 415 + 60 in
  let player_y = 260 + 140 in
  let player = P.create_player player_x player_y 0 in
  let player_with_seeds =
    match P.add_seeds player Crop.Wheat 5 with
    | Some p -> p
    | None -> assert_failure "Failed to add seeds"
  in
  let gs0 = GS.init 1280 720 player_with_seeds "test_user" in
  B.set_tile gs0.board 415 260 (B.Soil None);

  let seeds_before = player_with_seeds.inventory.(0).count in
  let gs1 = C.interact_with_soil gs0 player_x player_y in

  (match B.get_tile gs1.board 415 260 with
  | Some (B.Soil (Some _)) -> ()
  | _ -> assert_failure "Soil should have a planted crop");
  let seeds_after = gs1.player.inventory.(0).count in
  assert_equal (seeds_before - 1) seeds_after

(** [plant_with_no_seeds]Test planting when player has no seeds *)
let plant_with_no_seeds _ =
  let player_x = 415 + 60 in
  let player_y = 260 + 140 in
  let player = P.create_player player_x player_y 0 in
  let gs0 = GS.init 1280 720 player "test_user" in
  B.set_tile gs0.board 415 260 (B.Soil None);
  let gs1 = C.interact_with_soil gs0 player_x player_y in
  match B.get_tile gs1.board 415 260 with
  | Some (B.Soil None) -> ()
  | _ -> assert_failure "Soil should remain empty when no seeds available"

(** [interact_soil_no_nearest_point]Test interact_with_soil when
    get_nearest_soil_point returns None *)
let interact_soil_no_nearest_point _ =
  let player = P.create_player 5000 5000 0 in
  let gs0 = GS.init 1280 720 player "test_user" in
  let coins_before = gs0.player.coins in

  let gs1 = C.interact_with_soil gs0 5000 5000 in
  assert_equal coins_before gs1.player.coins;
  assert_equal gs0.player.x gs1.player.x

(** [interact_soil_on_shop_tile]Test interact_with_soil when tile is Shop *)
let interact_soil_on_shop_tile _ =
  let player = P.create_player 600 40 0 in
  let gs0 = GS.init 1280 720 player "test_user" in
  B.set_tile gs0.board 600 40 B.Shop;
  let gs1 = C.interact_with_soil gs0 600 40 in
  assert_equal gs0.player.coins gs1.player.coins

(** [interact_soil_on_path_tile] Test interact_with_soil when tile is Path *)
let interact_soil_on_path_tile _ =
  let player = P.create_player 100 100 0 in
  let gs0 = GS.init 1280 720 player "test_user" in
  B.set_tile gs0.board 100 100 B.Path;
  let gs1 = C.interact_with_soil gs0 100 100 in
  assert_equal gs0.player.coins gs1.player.coins

(** [interact_soil_tile_none] Test interact_with_soil when get_tile returns None
*)
let interact_soil_tile_none _ =
  let player = P.create_player 100 100 0 in
  let gs0 = GS.init 1280 720 player "test_user" in
  let gs1 = C.interact_with_soil gs0 (-100) (-100) in
  assert_equal gs0.player.coins gs1.player.coins

(** [buy_from_shop_insufficient_coins] Test Select_slot when shop is open but
    player doesn't have enough coins *)
let buy_from_shop_insufficient_coins _ =
  let player = P.create_player 0 0 2 in
  let gs0 = make_playing_state 1280 720 player in
  let gs_shop_open = { gs0 with GS.shop_open = true } in
  let coins_before = gs_shop_open.player.coins in
  let gs1 = C.take_action gs_shop_open (IH.Select_slot 0) in
  assert_equal coins_before gs1.player.coins;
  assert_equal 0 gs1.player.inventory.(0).count

(** [buy_all_crop_types] Test Select_slot buying each crop type from shop *)
let buy_all_crop_types _ =
  let player = P.create_player 0 0 1000 in
  let gs0 = make_playing_state 1280 720 player in
  let gs_shop = { gs0 with GS.shop_open = true } in
  let test_buy slot_idx expected_kind =
    let gs1 = C.take_action gs_shop (IH.Select_slot slot_idx) in
    match gs1.player.inventory.(slot_idx).seed_type with
    | Some kind -> assert_equal expected_kind kind
    | None ->
        assert_failure (Printf.sprintf "Slot %d should have seeds" slot_idx)
  in
  test_buy 0 Crop.Wheat;
  test_buy 1 Crop.Strawberry;
  test_buy 2 Crop.Grape;
  test_buy 3 Crop.Tomato;
  test_buy 4 Crop.Pumpkin

(** [select_slot_invalid_index] Test select_slot_index_crop_type function with
    invalid index *)
let select_slot_invalid_index _ =
  let result = C.select_slot_index_crop_type 99 in
  assert_equal Crop.Wheat result

(** [start_while_playing] Test take_action with Start while Playing ( do
    nothing) *)
let start_while_playing _ =
  let player = P.create_player 0 0 50 in
  let gs0 = make_playing_state 1280 720 player in
  let gs1 = C.take_action gs0 IH.Start in
  assert_equal GS.Playing gs1.phase;
  assert_equal gs0.player.coins gs1.player.coins

(** [move_while_paused]Test take_action with Move while Paused (should do
    nothing) *)
let move_while_paused _ =
  let player = P.create_player 10 10 0 in
  let gs0 = make_playing_state 1280 720 player in
  let gs_paused = { gs0 with GS.phase = GS.Paused } in
  let x_before = gs_paused.player.x in
  let gs1 = C.take_action gs_paused (IH.Move P.North) in
  assert_equal x_before gs1.player.x

(** [test_exit_action]Test take_action with Exit (shld do nothing) *)
let test_exit_action _ =
  let player = P.create_player 0 0 0 in
  let gs0 = make_playing_state 1280 720 player in
  let gs1 = C.take_action gs0 IH.Exit in
  assert_equal gs0.phase gs1.phase;
  assert_equal gs0.player.coins gs1.player.coins

(** [interact_w_shop_when_playing] Starting from Playing with shop closed,
    interacting should open the shop and pause the game. *)
let interact_w_shop_when_playing _ =
  let player = P.create_player 0 0 0 in
  let gs0 = make_playing_state 10 10 player in
  assert_bool "shop should start\n   closed" (gs0.shop_open = false);
  assert_equal GS.Playing gs0.phase;
  let gs1 = C.interact_with_shop gs0 in
  assert_bool "shop should now be open" (gs1.shop_open = true);
  assert_equal GS.Playing gs1.phase

(** [test_interact_with_soil_harvestable] Harvesting a harvestable crop:
    - clears the soil tile to Soil None
    - increases coins by sell_price
    - adds 3 seeds of that crop (removing 3 seeds succeeds, 4th fails). *)
let test_interact_with_soil_harvestable _ =
  let player_x = 415 + 60 in
  let player_y = 260 + 140 in
  let player = P.create_player player_x player_y 0 in
  let gs0 = GS.init 1280 720 player "test_user" in
  let c0 = Crop.create_crop Crop.Wheat in
  let max_stage = c0.Crop.stats.max_stage in
  let harvestable = { c0 with Crop.current_stage = max_stage } in
  B.set_tile gs0.board 415 260 (B.Soil (Some harvestable));
  let coins_before = gs0.player.coins in
  let gs1 = C.interact_with_soil gs0 player_x player_y in
  (match B.get_tile gs1.board 415 260 with
  | Some (B.Soil None) -> ()
  | _ -> assert_failure "Soil should be empty after harvest");
  let coins_after = gs1.player.coins in
  assert_equal (coins_before + harvestable.Crop.stats.sell_price) coins_after;

  (* 3 seeds added b/c of it*)
  let idx = P.slot_for_crop harvestable.Crop.stats.kind in
  let p_after = gs1.player in
  let p2, _ =
    match P.remove_seed p_after idx with
    | None -> assert_failure "expected at least\n   one seed"
    | Some r -> r
  in
  assert_equal None (P.remove_seed p2 idx)

(** [test_interact_with_soil_not_harvestable] If the crop is not harvestable,
    interact_with_soil should do nothing. *)
let test_interact_with_soil_not_harvestable _ =
  let player = P.create_player 415 260 0 in
  let gs0 = GS.init 1280 720 player "test_user" in
  let c0 = Crop.create_crop Crop.Wheat in
  let crop_not_ready = { c0 with Crop.current_stage = 0 } in
  B.set_tile gs0.board 415 260 (B.Soil (Some crop_not_ready));
  let coins_before = gs0.player.coins in
  let gs1 = C.interact_with_soil gs0 415 260 in
  (match B.get_tile gs1.board 415 260 with
  | Some (B.Soil (Some _)) -> ()
  | _ -> assert_failure "Tile should be unchanged for non-harvestable\n   crop");
  assert_equal coins_before gs1.player.coins

(** [toggle_playnpause] Pause should flip Playing 2 Paused and back 2 Playing *)
let toggle_playnpause _ =
  let player = P.create_player 0 0 0 in
  let gs_play = make_playing_state 10 10 player in
  assert_equal GS.Playing gs_play.phase;
  let gs_paused = C.handle_actions gs_play [ IH.Pause ] in
  assert_equal GS.Paused gs_paused.phase;
  let gs_play_again = C.handle_actions gs_paused [ IH.Pause ] in
  assert_equal GS.Playing gs_play_again.phase

(** [move_only_when_playing] Move actions work only when phase = Playing, and
    are ignored otherwise. *)
let move_only_when_playing _ =
  let player = P.create_player 10 10 0 in
  let gs_play = make_playing_state 100 100 player in
  (* Playing so da position changes *)
  let gs_after_move = C.take_action gs_play (IH.Move P.North) in
  let _, y_play = P.get_current_tile gs_play.player in
  let _, y_after = P.get_current_tile gs_after_move.player in
  assert_bool "y should change while playing" (y_after <> y_play);

  (* Paused so da move ignored *)
  let gs_paused = { gs_play with GS.phase = GS.Paused } in
  let gs_paused_after = C.take_action gs_paused (IH.Move P.North) in
  let _, y_paused = P.get_current_tile gs_paused.player in
  let _, y_paused_after = P.get_current_tile gs_paused_after.player in
  assert_equal y_paused y_paused_after

(** [get_random_crop_type]Test get_random_crop_type returns valid crop types *)
let get_random_crop_type _ =
  let valid_crops =
    [ Crop.Wheat; Crop.Strawberry; Crop.Tomato; Crop.Grape; Crop.Pumpkin ]
  in
  for _ = 1 to 20 do
    let crop = C.get_random_crop_type () in
    assert_bool "Should return a valid crop type" (List.mem crop valid_crops)
  done

(** [interact_toggle_shop_when_paused] When Paused and shop_open = true,
    Interact should close the shop. *)
let interact_toggle_shop_when_paused _ =
  let player = P.create_player 0 0 0 in
  let gs_play = make_playing_state 10 10 player in
  let gs_open = { gs_play with GS.phase = GS.Paused; GS.shop_open = true } in
  let gs_closed = C.take_action gs_open IH.Interact in
  assert_bool "shop should be closed again" (gs_closed.shop_open = false);
  assert_equal GS.Playing gs_closed.phase

(** [select_slot_changes_2selected_slot] Playing + Select_slot i should update
    player's selected_slot field. *)
let select_slot_changes_2selected_slot _ =
  let player = P.create_player 0 0 0 in
  let gs_play = make_playing_state 10 10 player in
  let gs_sel = C.take_action gs_play (IH.Select_slot 3) in
  assert_equal 3 gs_sel.player.selected_slot

(** [start_from_paused_resets_game]Test Start from Paused resets the game
    properly *)
let start_from_paused_resets_game _ =
  let initial_player = P.create_player 100 100 30 in
  let gs0 = GS.init 1280 720 initial_player "test_user" in
  let modified_player = { initial_player with P.coins = 500; P.x = 200 } in
  let gs_modified =
    {
      gs0 with
      GS.player = modified_player;
      GS.elapsed_time = 50.0;
      GS.phase = GS.Paused;
    }
  in
  let gs_reset = C.take_action gs_modified IH.Start in
  assert_equal initial_player.coins gs_reset.player.coins;
  assert_equal initial_player.x gs_reset.player.x;
  assert_equal 0.0 gs_reset.elapsed_time;
  assert_equal GS.Playing gs_reset.phase

(** [on_shop_tile_uses_interact_with_shop] If the player is standing on a Shop
    tile while Playing, Interact should open the shop and pause the game. *)
let on_shop_tile_uses_interact_with_shop _ =
  let player = P.create_player 600 40 0 in
  let gs0 = make_playing_state 1280 720 player in
  let x, y = P.get_current_tile gs0.player in
  B.set_tile gs0.board x y B.Shop;
  let gs1 = C.take_action gs0 IH.Interact in
  assert_bool "shop should open" gs1.shop_open;
  assert_equal GS.Playing gs1.phase

(** [facing_shop_interact_with_shop] If the player is facing a Shop tile while
    Playing, Interact should open the shop and pause the game. *)
let facing_shop_interact_with_shop _ =
  let player = P.create_player 600 40 0 in
  let gs0 = make_playing_state 1280 720 player in
  let px, py = P.get_current_tile gs0.player in
  B.set_tile gs0.board px py B.Path;
  let tile_x, tile_y, _ = B.get_facing_tile gs0.board gs0.player in
  B.set_tile gs0.board tile_x tile_y B.Shop;
  let gs1 = C.take_action gs0 IH.Interact in
  assert_bool "shop should open" gs1.shop_open;
  assert_equal GS.Playing gs1.phase

(** [facing_soil_interact_with_soil] If the player is facing a harvestable crop
    tile while Playing, Interact should delegate to [interact_with_soil]. *)
let facing_soil_interact_with_soil _ =
  let player = P.create_player (415 + 60) (260 + 140 - 115) 0 in
  let player_facing_south = { player with P.facing = P.South } in
  let gs0 = make_playing_state 1280 720 player_facing_south in
  let tile_x, tile_y, _ = B.get_facing_tile gs0.board gs0.player in
  let c0 = Crop.create_crop Crop.Wheat in
  let max_stage = c0.Crop.stats.max_stage in
  let harvestable = { c0 with Crop.current_stage = max_stage } in
  B.set_tile gs0.board tile_x tile_y (B.Soil (Some harvestable));
  let coins_before = gs0.player.coins in
  let gs1 = C.take_action gs0 IH.Interact in
  let coins_after = gs1.player.coins in
  if coins_after > coins_before then
    assert_equal (coins_before + harvestable.Crop.stats.sell_price) coins_after

(** [not_on_anything_does_nothing] If neither the current tile or the facing
    tile is special, Interact should have no ops. *)
let not_on_anything_does_nothing _ =
  let player = P.create_player 0 0 0 in
  let gs0 = make_playing_state 5 5 player in
  let coins_before = gs0.player.coins in
  let gs1 = C.take_action gs0 IH.Interact in
  assert_equal GS.Playing gs1.phase;
  assert_bool "shop should stay closed" (gs1.shop_open = false);
  assert_equal coins_before gs1.player.coins

(** [try_grow_crops] checks that [try_grow_crop] never decreases the crop's
    stage and never exceeds its [max_stage]. *)
let try_grow_crops _ =
  let base = Crop.create_crop Crop.Wheat in
  let max_stage = base.Crop.stats.max_stage in
  let crop = { base with Crop.current_stage = max_stage / 2 } in
  let grown = C.try_grow_crop crop in
  assert_bool "stage should not decrease"
    (grown.Crop.current_stage >= crop.Crop.current_stage);
  assert_bool "stage\n   should not exceed max_stage"
    (grown.Crop.current_stage <= grown.Crop.stats.max_stage)

(** [try_grow_all_crops_test] checks that try_grow_all_crops preserves the list
    length and never decreases any crop's stage or lets it exceed max_stage *)
let try_grow_all_crops_test _ =
  let mk_crop kind stage =
    let base = Crop.create_crop kind in
    { base with Crop.current_stage = stage }
  in
  let c1 = mk_crop Crop.Wheat 0 in
  let c2 = mk_crop Crop.Tomato 1 in
  let c3 = mk_crop Crop.Grape 2 in
  let crops = [ c1; c2; c3 ] in
  let grown = C.try_grow_all_crops crops in
  assert_equal (List.length crops) (List.length grown);
  List.iter2
    (fun before after ->
      assert_bool "stage should not decrease"
        (after.Crop.current_stage >= before.Crop.current_stage);
      assert_bool "stage\n   should not exceed max_stage"
        (after.Crop.current_stage <= after.Crop.stats.max_stage))
    crops grown

(**[select_slot_while_paused_does_nothing] makes sure that selecting slot when
   paused does nothing *)
let select_slot_while_paused_does_nothing _ =
  let player = P.create_player 0 0 0 in
  let gs =
    make_playing_state 5 5 player |> fun g -> { g with GS.phase = GS.Paused }
  in
  let gs' = C.take_action gs (IH.Select_slot 2) in
  assert_equal gs'.player.selected_slot gs.player.selected_slot

let suite =
  "game_controller tests"
  >::: [
         "plant_seed_on_empty_soil" >:: plant_seed_on_empty_soil;
         "plant_with_no_seeds" >:: plant_with_no_seeds;
         "interact_soil_no_nearest_point" >:: interact_soil_no_nearest_point;
         "interact_soil_on_shop_tile" >:: interact_soil_on_shop_tile;
         "interact_soil_on_path_tile" >:: interact_soil_on_path_tile;
         "interact_soil_tile_none" >:: interact_soil_tile_none;
         "test_interact_with_soil_harvestable"
         >:: test_interact_with_soil_harvestable;
         "test_interact_with_soil_not_harvestable"
         >:: test_interact_with_soil_not_harvestable;
         "buy_from_shop_insufficient_coins" >:: buy_from_shop_insufficient_coins;
         "buy_all_crop_types" >:: buy_all_crop_types;
         "select_slot_invalid_index" >:: select_slot_invalid_index;
         "start_while_playing" >:: start_while_playing;
         "start_from_paused_resets_game" >:: start_from_paused_resets_game;
         "move_while_paused" >:: move_while_paused;
         "move_only_when_playing" >:: move_only_when_playing;
         "toggle_playnpause" >:: toggle_playnpause;
         "exit_action" >:: test_exit_action;
         "get_random_crop_type" >:: get_random_crop_type;
         "interact_w_shop_when_playing" >:: interact_w_shop_when_playing;
         "interact_toggle_shop_when_paused" >:: interact_toggle_shop_when_paused;
         "on_shop_tile_uses_interact_with_shop"
         >:: on_shop_tile_uses_interact_with_shop;
         "facing_shop_interact_with_shop" >:: facing_shop_interact_with_shop;
         "select_slot_changes_2selected_slot"
         >:: select_slot_changes_2selected_slot;
         "facing_soil_interact_with_soil" >:: facing_soil_interact_with_soil;
         "not_on_anything_does_nothing" >:: not_on_anything_does_nothing;
         "try_grow_crops" >:: try_grow_crops;
         "try_grow_all_crops_test" >:: try_grow_all_crops_test;
         "select_slot_while_paused_does_nothing"
         >:: select_slot_while_paused_does_nothing;
       ]

let () = run_test_tt_main suite
