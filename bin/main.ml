module P = Model.Player
module PR = View.Player_render
module I = Controller.Input_handler
module C = Controller.Game_controller
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

  let board_width = 1280 in
  let board_height = 720 in
  let player = ref (P.create_player 100 100 0) in

  while not (window_should_close ()) do
    let elapsed = get_time () -. start_time in

    (* ------------------------- *)
    (* GAME LOGIC *)
    let actions = I.check_input () in
    I.print_inputs actions;
    player := C.handle_actions board_width board_height !player actions;

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
    PR.draw_player !player delta_time moving;

    end_drawing ()
  done;

  (* ------------------------- *)
  (* CLEANUP *)
  PR.unload_assets ();
  Array.iter unload_texture frames;
  close_window ()
