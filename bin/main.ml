module P = Model.Player
module Crop = Model.Crop
module PR = View.Player_render
module CR = View.Crop_render
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

  PR.load_assets ();

  CR.load_assets ();
  let board_width = 1200 in
  let board_height = 600 in
  let initial_player = P.create_player 100 100 0 in
  let game_state =
    ref (GS.init board_width board_height initial_player |> GS.start)
  in
  let crops = ref (C.create_initial_crops 12) in
  let crop_grow_interval = 5.0 in
  let last_crop_grow_time = ref 0.0 in

  while not (window_should_close ()) do
    let elapsed = get_time () -. start_time in

    (* ------------------------- *)
    (* GAME LOGIC: PLAYER INPUTS *)
    let actions = I.check_input () in
    I.print_inputs actions;
    game_state := C.handle_actions !game_state actions;

    (* GAME LOGIC: CROP GROWTH (every 5s) *)
    if elapsed -. !last_crop_grow_time >= crop_grow_interval then (
      crops := C.try_grow_all_crops !crops;
      last_crop_grow_time := elapsed);

    (* Determine if the player is moving *)
    let moving =
      List.exists
        (function
          | I.Move _ -> true
          | _ -> false)
        actions
    in

    (* ------------------------- *)
    (* BACKGROUND ANIMATION *)
    let cycle_time = durations.(0) +. durations.(1) in
    let t = mod_float elapsed cycle_time in
    let frame_index = if t < durations.(0) then 0 else 1 in

    (* ------------------------- *)
    (* DRAWING *)
    begin_drawing ();
    clear_background Color.raywhite;

    (* Draw background first *)
    draw_texture frames.(frame_index) 0 0 Color.white;

    (* Draw player on top *)
    let delta_time = get_frame_time () in
    let player = !game_state.GS.player in
    PR.draw_player player delta_time moving;

    (* Draw crops on top *)
    (* TODO: currently, the crops have hardcoded draw locations. 
    We will need to draw them where the user planted them in the future. *)

    (* Row 1 *)
    CR.draw_crop (List.nth !crops 0) 400.0 250.0;
    CR.draw_crop (List.nth !crops 1) 500.0 250.0;
    CR.draw_crop (List.nth !crops 2) 600.0 250.0;
    CR.draw_crop (List.nth !crops 3) 700.0 250.0;

    (* Row 2 *)
    CR.draw_crop (List.nth !crops 4) 400.0 350.0;
    CR.draw_crop (List.nth !crops 5) 500.0 350.0;
    CR.draw_crop (List.nth !crops 6) 600.0 350.0;
    CR.draw_crop (List.nth !crops 7) 700.0 350.0;

    (* Row 3 *)
    CR.draw_crop (List.nth !crops 8) 400.0 450.0;
    CR.draw_crop (List.nth !crops 9) 500.0 450.0;
    CR.draw_crop (List.nth !crops 10) 600.0 450.0;
    CR.draw_crop (List.nth !crops 11) 700.0 450.0;
    end_drawing ()
  done;

  (* ------------------------- *)
  (* CLEANUP *)
  PR.unload_assets ();
  CR.unload_assets ();
  Array.iter unload_texture frames;
  close_window ()
