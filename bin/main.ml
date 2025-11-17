module P = Model.Player
module I = Controller.Input_handler
module C = Controller.Game_controller
open Raylib

let () =
  init_window 1280 720 "Cameldew Valley!";
  set_target_fps 60;

  let frames =
    [|
      (* default frame *)
      load_texture "assets/bg_frame1.png";
      (* windy frame *)
      load_texture "assets/bg_frame2.png";
    |]
  in

  let durations = [| 3.0; 0.5 |] in
  (* 3000 ms and 5.0 ms *)

  let start_time = get_time () in

  (* let board_width = 1280 in let board_height = 720 in let player = ref
     (P.create_player 100 100 0) in *)
  while not (window_should_close ()) do
    let elapsed = get_time () -. start_time in

    (* GAME LOGIC *)
    let actions = I.check_input () in
    I.print_inputs actions;

    (* player := C.handle_actions board_width board_height !player actions; *)
    let cycle_time = durations.(0) +. durations.(1) in
    let t = mod_float elapsed cycle_time in
    let frame_index = if t < durations.(0) then 0 else 1 in

    begin_drawing ();
    draw_texture frames.(frame_index) 0 0 Color.white;
    end_drawing ()
  done;

  Array.iter unload_texture frames;
  close_window ()
