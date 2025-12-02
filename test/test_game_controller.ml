(* open OUnit2
module GS = Model.Game_state
module P = Model.Player
module B = Model.Board
module Crop = Model.Crop
module IH = Controller.Input_handler
module C = Controller.Game_controller

(* helper func to produce a game w playing state *)
let make_playing_state width height player =
  GS.start (GS.init width height player)

(** [move_changes_loc] Checks that [move gs dir] updates the player in the same
    way as calling [Player.move_player] directly. *)
let move_changes_loc _ =
  let player = P.create_player 10 10 0 in
  let gs = make_playing_state 100 100 player in

  let gs' = C.handle_actions gs [ IH.Move P.North ] in
  let expected_player = P.move_player player P.North 100 100 in

  let exp_x, exp_y = P.get_current_tile expected_player in
  let act_x, act_y = P.get_current_tile gs'.player in
  assert_equal exp_x act_x;
  assert_equal exp_y act_y;
  assert_equal expected_player.facing gs'.player.facing

(** [interact_w_shop_when_playing] Starting from Playing with shop closed,
    interacting should open the shop and pause the game. *)
let interact_w_shop_when_playing _ =
  let player = P.create_player 0 0 0 in
  let gs0 = make_playing_state 10 10 player in
  assert_bool "shop should start closed" (gs0.shop_open = false);
  assert_equal GS.Playing gs0.phase;

  let gs1 = C.interact_with_shop gs0 in
  assert_bool "shop should now be open" (gs1.shop_open = true);
  assert_equal GS.Paused gs1.phase

(** [interact_w_shop_when_paused] Starting from Paused with shop open,
    interacting should close the shop and resume Playing. *)
let interact_w_shop_when_paused _ =
  let player = P.create_player 0 0 0 in
  let gs_play = make_playing_state 10 10 player in
  let gs_open = C.interact_with_shop gs_play in
  let gs_closed = C.interact_with_shop gs_open in
  assert_bool "shop should be closed again" (gs_closed.shop_open = false);
  assert_equal GS.Playing gs_closed.phase

(** [test_interact_with_soil_harvestable] Harvesting a harvestable crop: -
    clears the soil tile to [Soil None] - increases coins by [sell_price] - adds
    3 seeds of that crop (removing 3 seeds succeeds, 4th fails). *)
let test_interact_with_soil_harvestable _ =
  let player = P.create_player 1 1 0 in
  let gs0 = GS.init 3 3 player in

  let c0 = Crop.create_crop Crop.Wheat in
  let max_stage = c0.Crop.stats.max_stage in
  let harvestable = { c0 with Crop.current_stage = max_stage } in

  B.set_tile gs0.board 1 2 (B.Soil (Some harvestable));
  let coins_before = gs0.player.coins in
  let gs1 = C.interact_with_soil gs0 1 2 harvestable in

  (* soil shld b cleared *)
  (match B.get_tile gs1.board 1 2 with
  | Some (B.Soil None) -> ()
  | _ -> assert_failure "Soil should be empty after harvest");

  (* coins increased by sell_price *)
  let coins_after = gs1.player.coins in
  assert_equal (coins_before + harvestable.Crop.stats.sell_price) coins_after;

  (* 3 seeds added b/c of it*)
  let idx = P.slot_for_crop harvestable.Crop.stats.kind in
  let p_after = gs1.player in
  let p2, _ =
    match P.remove_seed p_after idx with
    | None -> assert_failure "expected at least one seed"
    | Some r -> r
  in
  let p3, _ =
    match P.remove_seed p2 idx with
    | None -> assert_failure "expected second seed"
    | Some r -> r
  in
  let p4, _ =
    match P.remove_seed p3 idx with
    | None -> assert_failure "expected third seed"
    | Some r -> r
  in
  (* now slot is empty n another remove_seed should not work *)
  assert_equal None (P.remove_seed p4 idx)

(** [test_interact_with_soil_not_harvestable] If the crop is not harvestable,
    interact_with_soil should do nothing. *)
let test_interact_with_soil_not_harvestable _ =
  let player = P.create_player 1 1 0 in
  let gs0 = GS.init 3 3 player in

  let c0 = Crop.create_crop Crop.Wheat in
  let crop_not_ready = { c0 with Crop.current_stage = 0 } in

  B.set_tile gs0.board 1 2 (B.Soil (Some crop_not_ready));
  let coins_before = gs0.player.coins in

  let gs1 = C.interact_with_soil gs0 1 2 crop_not_ready in

  (* unchanged *)
  (match B.get_tile gs1.board 1 2 with
  | Some (B.Soil (Some _)) -> ()
  | _ -> assert_failure "Tile should be unchanged for non-harvestable crop");

  (* unchanged *)
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

(** [pause_shld_use_toggle] Pause action should delegate to
    [Game_state.toggle_pause]. *)
let pause_shld_use_toggle _ =
  let player = P.create_player 0 0 0 in
  let gs_play = make_playing_state 10 10 player in
  let gs_paused = C.take_action gs_play IH.Pause in
  assert_equal GS.Paused gs_paused.phase;
  let gs_play_again = C.take_action gs_paused IH.Pause in
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

(** [interact_toggle_shop_when_paused] When Paused and shop_open = true,
    Interact should close the shop. *)
let interact_toggle_shop_when_paused _ =
  let player = P.create_player 0 0 0 in
  let gs_play = make_playing_state 10 10 player in
  let gs_open = C.interact_with_shop gs_play in
  (* now shop_open = true, phase = Paused *)
  let gs_closed = C.take_action gs_open IH.Interact in
  assert_bool "shop should be closed again" (gs_closed.shop_open = false)

(** [select_slot_changes_2selected_slot] Playing + Select_slot i should update
    player's selected_slot field. *)
let select_slot_changes_2selected_slot _ =
  let player = P.create_player 0 0 0 in
  let gs_play = make_playing_state 10 10 player in
  let gs_sel = C.take_action gs_play (IH.Select_slot 3) in
  assert_equal 3 gs_sel.player.selected_slot

(** [on_shop_tile_uses_interact_with_shop] If the player is standing on a Shop
    tile while Playing, Interact should open the shop and pause the game. *)
let on_shop_tile_uses_interact_with_shop _ =
  let player = P.create_player 0 0 0 in
  let gs0 = make_playing_state 5 5 player in
  let x, y = P.get_current_tile gs0.player in
  B.set_tile gs0.board x y B.Shop;
  let gs1 = C.take_action gs0 IH.Interact in
  assert_bool "shop should open" gs1.shop_open;
  assert_equal GS.Paused gs1.phase

(** [facing_shop_interact_with_shop] If the player is facing a Shop tile while
    Playing, Interact should open the shop and pause the game. *)
let facing_shop_interact_with_shop _ =
  let player = P.create_player 0 0 0 in
  let gs0 = make_playing_state 5 5 player in
  let tile_x, tile_y, _ = B.get_facing_tile gs0.board gs0.player in
  B.set_tile gs0.board tile_x tile_y B.Shop;
  let gs1 = C.take_action gs0 IH.Interact in
  assert_bool "shop should open" gs1.shop_open;
  assert_equal GS.Paused gs1.phase

(** [facing_soil_interact_with_soil] If the player is facing a harvestable crop
    tile while Playing, Interact should delegate to [interact_with_soil]. *)
let facing_soil_interact_with_soil _ =
  let player = P.create_player 1 1 0 in
  let gs0 = make_playing_state 3 3 player in
  let tile_x, tile_y, _ = B.get_facing_tile gs0.board gs0.player in

  let c0 = Crop.create_crop Crop.Wheat in
  let max_stage = c0.Crop.stats.max_stage in
  let harvestable = { c0 with Crop.current_stage = max_stage } in
  B.set_tile gs0.board tile_x tile_y (B.Soil (Some harvestable));

  let coins_before = gs0.player.coins in
  let gs1 = C.take_action gs0 IH.Interact in

  (* soil shld b cleared by da interact_with_soil *)
  (match B.get_tile gs1.board tile_x tile_y with
  | Some (B.Soil None) -> ()
  | _ -> assert_failure "Soil should be empty after harvest via Interact");

  let coins_after = gs1.player.coins in
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

(** [create_initial_crops_len] checks that [create_initial_crops] always returns
    a list of exactly 12 crops. *)
let create_initial_crops_len _ =
  Random.init 42;
  let crops = C.create_initial_crops 7 in
  assert_equal 12 (List.length crops)

(** [try_grow_crops] checks that [try_grow_crop] never decreases the crop's
    stage and never exceeds its [max_stage]. *)
let try_grow_crops _ =
  let base = Crop.create_crop Crop.Wheat in
  let max_stage = base.Crop.stats.max_stage in
  let crop = { base with Crop.current_stage = max_stage / 2 } in
  let grown = C.try_grow_crop crop in
  assert_bool "stage should not decrease"
    (grown.Crop.current_stage >= crop.Crop.current_stage);
  assert_bool "stage should not exceed max_stage"
    (grown.Crop.current_stage <= grown.Crop.stats.max_stage)

(** [try_grow_all_crops_test] checks that [try_grow_all_crops] preserves the
    list length and never decreases any crop's stage or lets it exceed
    [max_stage]. *)
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
      assert_bool "stage should not exceed max_stage"
        (after.Crop.current_stage <= after.Crop.stats.max_stage))
    crops grown

let suite =
  "game_controller tests"
  >::: [
         "move_changes_loc" >:: move_changes_loc;
         "toggle_playnpause" >:: toggle_playnpause;
         "interact_w_shop_when_playing" >:: interact_w_shop_when_playing;
         "interact_w_shop_when_paused" >:: interact_w_shop_when_paused;
         "test_interact_with_soil_harvestable"
         >:: test_interact_with_soil_harvestable;
         "test_interact_with_soil_not_harvestable"
         >:: test_interact_with_soil_not_harvestable;
         "pause_shld_use_toggle" >:: pause_shld_use_toggle;
         "move_only_when_playing" >:: move_only_when_playing;
         "interact_toggle_shop_when_paused" >:: interact_toggle_shop_when_paused;
         "select_slot_changes_2selected_slot"
         >:: select_slot_changes_2selected_slot;
         "on_shop_tile_uses_interact_with_shop"
         >:: on_shop_tile_uses_interact_with_shop;
         "facing_shop_interact_with_shop" >:: facing_shop_interact_with_shop;
         "facing_soil_interact_with_soil" >:: facing_soil_interact_with_soil;
         "not_on_anything_does_nothing" >:: not_on_anything_does_nothing;
         "create_initial_crops_len" >:: create_initial_crops_len;
         "try_grow_crops" >:: try_grow_crops;
         "try_grow_all_crops_test" >:: try_grow_all_crops_test;
       ]

let () = run_test_tt_main suite *)
