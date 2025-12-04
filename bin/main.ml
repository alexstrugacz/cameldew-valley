module P = Model.Player
module Crop = Model.Crop
module B = Model.Board
module PR = View.Player_render
module CR = View.Crop_render
module IR = View.Inventory_render
module CO = View.Coin_render
module CL = View.Clock_render
module SR = View.Shop_render
module PS = View.Pause_render
module LR = View.Leaderboard_render
module ST = View.Start
module I = Controller.Input_handler
module C = Controller.Game_controller
module GS = Model.Game_state
module LB = Model.Leaderboard
open Raylib

let () =
  init_window 1280 720 "Cameldew Valley!";
  set_target_fps 60;

  (* Background frames *)
  let frames =
    [|
      load_texture "assets/background/bg_frame1.png";
      load_texture "assets/background/bg_frame2.png";
    |]
  in
  let durations = [| 3.0; 0.5 |] in
  let start_time = get_time () in

  (* Initialize database *)
  LB.init_db ();

  (* Load assets *)
  PR.load_assets ();
  CR.load_assets ();
  IR.load_assets ();
  CO.load ();
  CL.load ();
  SR.load_assets ();
  LR.load ();
  ST.load ();
  PS.load ();
  (* Game configuration *)
  let game_duration = 120.0 in
  let board_width = 1200 in
  let board_height = 700 in

  (* Get username from start screen *)
  let final_username = ST.get_username () in

  (* Initialize game state *)
  let initial_player = P.create_player 100 100 30 in
  let game_state =
    ref
      (GS.init board_width board_height initial_player final_username
      |> GS.start)
  in
  let crop_grow_interval = 5.0 in
  let last_crop_grow_time = ref 0.0 in
  let game_ended = ref false in
  let showing_leaderboard = ref false in
  let leaderboard_scores = ref [] in

  while not (window_should_close ()) do
    let elapsed = get_time () -. start_time in
    let delta_time = get_frame_time () in

    (* ------------------------- *)
    (* GAME LOGIC *)
    if !showing_leaderboard then (
      if
        (* Leaderboard mode *)
        is_key_pressed Key.Escape
      then (
        showing_leaderboard := false;
        game_ended := false;
        (* Reset game *)
        let new_player = P.create_player 100 100 30 in
        game_state :=
          GS.init board_width board_height new_player final_username |> GS.start;
        last_crop_grow_time := 0.0))
    else if !game_ended then (
      (* Game ended, show leaderboard *)
      showing_leaderboard := true;
      leaderboard_scores := LB.get_top_scores 10)
    else (
      (* Normal game play *)
      if !game_state.GS.phase = GS.Playing then (
        game_state :=
          {
            !game_state with
            GS.elapsed_time = !game_state.GS.elapsed_time +. delta_time;
          };

        (* Check if game time is up *)
        if !game_state.GS.elapsed_time >= game_duration then (
          (* Game ended - save score *)
          let final_coins = !game_state.GS.player.coins in
          LB.save_score final_username final_coins;
          game_state := GS.stop !game_state;
          game_ended := true));

      let actions = I.check_input () in

      let filtered_actions =
        if !game_state.GS.shop_open then
          (* When in shop: block movement & interact, except F is allowed only
             when Playing *)
          List.filter
            (fun action ->
              match (!game_state.GS.phase, action) with
              | GS.Playing, I.Interact -> true (* F closes shop *)
              | _, I.Select_slot _ | _, I.Pause | _, I.Exit | _, I.Start -> true
              | _ -> false)
            actions
        else
          (* Normal phase-based filtering *)
          match !game_state.GS.phase with
          | GS.Paused ->
              List.filter
                (function
                  | I.Pause | I.Exit -> true
                  | _ -> false)
                actions
          | GS.Playing -> actions
          | GS.NotPlaying -> actions
      in

      game_state := C.handle_actions !game_state filtered_actions;

      if
        !game_state.GS.phase = GS.Playing
        && !game_state.GS.elapsed_time -. !last_crop_grow_time
           >= crop_grow_interval
      then (
        let board = !game_state.GS.board in
        B.board_iterate
          (fun x y tile ->
            match tile with
            | B.Soil (Some crop) ->
                board.(y).(x) <- B.Soil (Some (Crop.try_grow crop))
            | _ -> ())
          board;
        last_crop_grow_time := !game_state.GS.elapsed_time);

      (* Player movement should use filtered actions, so basically it won't move
         when paused *)
      let moving =
        List.exists
          (function
            | I.Move _ -> true
            | _ -> false)
          filtered_actions
      in

      (* Background animation *)
      let cycle_time = durations.(0) +. durations.(1) in
      let t = mod_float elapsed cycle_time in
      let frame_index = if t < durations.(0) then 0 else 1 in

      (* ------------------------- *)
      (* DRAWING *)
      begin_drawing ();
      clear_background Color.raywhite;

      (* Background *)
      draw_texture frames.(frame_index) 0 0 Color.white;

      (* Player layer logic *)
      let player = !game_state.GS.player in
      let board = !game_state.GS.board in
      B.board_iterate
        (fun x y tile ->
          match tile with
          | B.Soil (Some crop) ->
              CR.draw_crop crop (float_of_int x) (float_of_int y)
          | _ -> ())
        board;

      PR.draw_player player delta_time moving;

      (* Draw UI elements *)
      IR.draw_inventory player;
      CO.draw_coin player;
      CL.draw_clock !game_state.GS.elapsed_time;

      (* ------------------------- *)
      (* Draw Shop if open *)
      SR.draw_shop !game_state.GS.shop_open;

      if !game_state.GS.phase = GS.Paused then PS.draw_pause ();

      end_drawing ());

    (* Drawing leaderboard if showing *)
    if !showing_leaderboard then (
      begin_drawing ();
      clear_background Color.black;
      LR.draw_leaderboard !leaderboard_scores;
      end_drawing ())
  done;

  (* ------------------------- *)
  (* CLEANUP *)
  PR.unload_assets ();
  CR.unload_assets ();
  IR.unload_assets ();
  CO.unload ();
  CL.unload ();
  SR.unload_assets ();
  LR.unload ();
  ST.unload ();
  PS.unload ();
  Array.iter unload_texture frames;
  close_window ()
