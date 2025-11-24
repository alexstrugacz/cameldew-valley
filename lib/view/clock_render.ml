open Raylib

let clock_texture = ref None
let scale = 0.25
let font = ref None

let load () =
  clock_texture := Some (load_texture "assets/display/clock-display.png");
  font := Some (load_font "assets/fonts/PressStart2P-Regular.ttf")

let unload () =
  begin
    (match !clock_texture with
    | Some t -> unload_texture t
    | None -> ());

    match !font with
    | Some f -> unload_font f
    | None -> ()
  end

let draw_clock () =
  match !clock_texture with
  | None -> ()
  | Some tex ->
      let x = 1045 in
      let y = 7 in
      let pos = Vector2.create (float_of_int x) (float_of_int y) in
      draw_texture_ex tex pos 0.0 scale Color.white
