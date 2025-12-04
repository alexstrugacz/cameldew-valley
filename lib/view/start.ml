(** Start screen module for username input *)

module I = Controller.Input_handler
open Raylib

let font = ref None
let bg = ref None
let sign = ref None
let nameplate = ref None

let load () =
  font := Some (load_font "assets/fonts/PressStart2P-Regular.ttf");
  bg := Some (load_texture "assets/title/title-bg.png");
  sign := Some (load_texture "assets/title/cameldew.png");
  nameplate := Some (load_texture "assets/title/name.png")

let unload () =
  (match !font with
  | Some f -> unload_font f
  | None -> ());
  (match !bg with
  | Some t -> unload_texture t
  | None -> ());
  match !sign with
  | Some t -> unload_texture t
  | None -> ()

(** [get_username ()] displays the start screen and returns the username entered
*)
let get_username () =
  let username = ref "" in
  let username_input_active = ref true in
  let sign_y =
    ref (-35.0)
    (* start off-screen above *)
  in
  let target_y =
    50.0
    (* final position *)
  in
  let speed =
    1.45
    (* pixels per frame *)
  in

  while !username_input_active && not (window_should_close ()) do
    begin_drawing ();
    clear_background Color.black;

    (* Draw the background image *)
    (match !bg with
    | Some tex -> draw_texture tex 0 0 Color.white
    | None -> ());

    (* Animate the sign sliding down *)
    if !sign_y < target_y then sign_y := !sign_y +. speed;
    (match !sign with
    | Some tex ->
        let sign_x = 640 - 306 in
        draw_texture tex sign_x (int_of_float !sign_y) Color.white
    | None -> ());

    (match !nameplate with
    | Some tex ->
        draw_texture_ex tex
          (Vector2.create (640.0 -. 172.8) 470.0)
          0.0 0.3 Color.white
    | None -> ());

    (* Draw text *)
    (match !font with
    | None -> ()
    | Some username_font ->
        let prompt_spacing = 0.5 in

        let input_text =
          if String.length !username > 0 then !username else "player"
        in
        let input_size = 18.0 in
        let input_size_vec =
          measure_text_ex username_font input_text input_size prompt_spacing
        in
        let input_x = (1280.0 -. Vector2.x input_size_vec) /. 2.0 in
        let input_y = 504.0 in
        draw_text_ex username_font input_text
          (Vector2.create input_x input_y)
          input_size prompt_spacing Color.yellow;

        let instruction = "Type your name and press ENTER to start!" in
        let inst_size = 18.0 in
        let inst_size_vec =
          measure_text_ex username_font instruction inst_size prompt_spacing
        in
        let inst_x = (1280.0 -. Vector2.x inst_size_vec) /. 2.0 in
        let inst_y = 580.0 in
        draw_text_ex username_font instruction
          (Vector2.create inst_x inst_y)
          inst_size prompt_spacing Color.black;
        draw_text_ex username_font instruction
          (Vector2.create (inst_x +. 2.0) (inst_y +. 2.0))
          inst_size prompt_spacing Color.white;

        (* Handle text input *)
        (match I.get_text_input () with
        | Some c -> username := !username ^ String.make 1 c
        | None -> ());
        if I.is_backspace_pressed () && String.length !username > 0 then
          username := String.sub !username 0 (String.length !username - 1);
        if is_key_pressed Key.Enter then (
          if String.length !username = 0 then username := "player";
          username_input_active := false));

    end_drawing ()
  done;

  if String.length !username = 0 then "player" else !username
