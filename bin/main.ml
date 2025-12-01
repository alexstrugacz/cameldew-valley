module P = Model.Player
module Crop = Model.Crop
module B = Model.Board
module PR = View.Player_render
module CR = View.Crop_render
module IR = View.Inventory_render
module CO = View.Coin_render
module CL = View.Clock_render
module SR = View.Shop_render
module I = Controller.Input_handler
module C = Controller.Game_controller
module GS = Model.Game_state
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

  (* Load assets *)
  PR.load_assets ();
  CR.load_assets ();
  IR.load_assets ();
  CO.load ();
  CL.load ();
  SR.load_assets ();

  let board_width = 1200 in
  let board_height = 600 in
  let initial_player = P.create_player 100 100 30 in
  let game_state =
    ref (GS.init board_width board_height initial_player |> GS.start)
  in
  (* COMMENT OUT OLD HARD-CODED CROP GROWTH CODE  *)
  (* let crops = ref (C.create_initial_crops 12) in  *)
  let crop_grow_interval = 5.0 in
  let last_crop_grow_time = ref 0.0 in

  while not (window_should_close ()) do
    let elapsed = get_time () -. start_time in
    let delta_time = get_frame_time () in

    (* ------------------------- *)
    (* GAME LOGIC *)
    if !game_state.GS.phase = GS.Playing then
      game_state :=
        {
          !game_state with
          GS.elapsed_time = !game_state.GS.elapsed_time +. delta_time;
        };

    let actions = I.check_input () in
    I.print_inputs actions;
    game_state := C.handle_actions !game_state actions;

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

    (* Player movement check *)
    let moving =
      List.exists
        (function
          | I.Move _ -> true
          | _ -> false)
        actions
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

    (* COMMENT OUT PREVIOUS CROP HARDCODED CROP RENDER CODE *)

    (* let layer = match player.y with | x when x < 200 -> 1 | x when x < 310 ->
       2 | x when x < 420 -> 3 | _ -> 4 in *)

    (* (* Draw crops and player based on layers *) if layer = 1 then
       PR.draw_player player delta_time moving; CR.draw_crop (List.nth !crops 0)
       415.0 260.0; CR.draw_crop (List.nth !crops 1) 555.0 260.0; CR.draw_crop
       (List.nth !crops 2) 695.0 260.0; CR.draw_crop (List.nth !crops 3) 835.0
       260.0;

       if layer = 2 then PR.draw_player player delta_time moving; CR.draw_crop
       (List.nth !crops 4) 415.0 370.0; CR.draw_crop (List.nth !crops 5) 555.0
       370.0; CR.draw_crop (List.nth !crops 6) 695.0 370.0; CR.draw_crop
       (List.nth !crops 7) 835.0 370.0;

       if layer = 3 then PR.draw_player player delta_time moving; CR.draw_crop
       (List.nth !crops 8) 415.0 480.0; CR.draw_crop (List.nth !crops 9) 555.0
       480.0; CR.draw_crop (List.nth !crops 10) 695.0 480.0; CR.draw_crop
       (List.nth !crops 11) 835.0 480.0; if layer = 4 then *)

    (* NEW CROP RENDER CODE *)
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

    end_drawing ()
  done;

  (* ------------------------- *)
  (* CLEANUP *)
  PR.unload_assets ();
  CR.unload_assets ();
  IR.unload_assets ();
  CO.unload ();
  CL.unload ();
  SR.unload_assets ();
  Array.iter unload_texture frames;
  close_window ()
