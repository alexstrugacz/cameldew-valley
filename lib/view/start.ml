(** Start screen module for username input *)

module I = Controller.Input_handler
open Raylib

let font = ref None

let load () = font := Some (load_font "assets/fonts/PressStart2P-Regular.ttf")

let unload () =
  match !font with Some f -> unload_font f | None -> ()

(** [get_username ()] displays the start screen and returns the username entered *)
let get_username () =
  let username = ref "" in
  let username_input_active = ref true in

  while !username_input_active && not (window_should_close ()) do
    begin_drawing ();
    clear_background Color.black;

    match !font with
    | None -> ()
    | Some username_font ->
        let prompt = "Enter your username:" in
        let prompt_size = 32.0 in
        let prompt_spacing = 2.0 in
        let prompt_size_vec =
          measure_text_ex username_font prompt prompt_size prompt_spacing
        in
        let prompt_x = (1280.0 -. Vector2.x prompt_size_vec) /. 2.0 in
        let prompt_y = 300.0 in

        draw_text_ex username_font prompt
          (Vector2.create prompt_x prompt_y)
          prompt_size prompt_spacing Color.white;

        let input_text =
          if String.length !username > 0 then !username else "player"
        in
        let input_size = 28.0 in
        let input_size_vec =
          measure_text_ex username_font input_text input_size prompt_spacing
        in
        let input_x = (1280.0 -. Vector2.x input_size_vec) /. 2.0 in
        let input_y = 350.0 in

        draw_text_ex username_font input_text
          (Vector2.create input_x input_y)
          input_size prompt_spacing Color.yellow;

        let instruction = "Type your name and press ENTER to start" in
        let inst_size = 18.0 in
        let inst_size_vec =
          measure_text_ex username_font instruction inst_size prompt_spacing
        in
        let inst_x = (1280.0 -. Vector2.x inst_size_vec) /. 2.0 in
        let inst_y = 400.0 in

        draw_text_ex username_font instruction
          (Vector2.create inst_x inst_y)
          inst_size prompt_spacing Color.gray;

        (* Handle text input using input_handler *)
        (match I.get_text_input () with
        | Some c -> username := !username ^ String.make 1 c
        | None -> ());

        if I.is_backspace_pressed () && String.length !username > 0 then
          username := String.sub !username 0 (String.length !username - 1);

        if is_key_pressed Key.Enter then (
          if String.length !username = 0 then username := "player";
          username_input_active := false
        );

    end_drawing ()
  done;

  if String.length !username = 0 then "player" else !username

