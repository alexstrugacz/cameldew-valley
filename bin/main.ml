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

  while not (window_should_close ()) do
    let elapsed = get_time () -. start_time in

    let cycle_time = durations.(0) +. durations.(1) in
    let t = mod_float elapsed cycle_time in
    let frame_index = if t < durations.(0) then 0 else 1 in

    begin_drawing ();
    draw_texture frames.(frame_index) 0 0 Color.white;
    end_drawing ()
  done;

  Array.iter unload_texture frames;
  close_window ()
