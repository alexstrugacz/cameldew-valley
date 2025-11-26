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

let format_time (seconds : float) : string =
  let total_seconds = int_of_float seconds in
  let minutes = total_seconds / 60 in
  let secs = total_seconds mod 60 in
  Printf.sprintf "%02d:%02d" minutes secs

let draw_clock (elapsed_time : float) =
  match (!clock_texture, !font) with
  | None, _ | _, None -> ()
  | Some tex, Some f ->
      let x = 1045 in
      let y = 7 in
      let pos = Vector2.create (float_of_int x) (float_of_int y) in
      draw_texture_ex tex pos 0.0 scale Color.white;

      (* Draw time text on top of clock *)
      let time_str = format_time elapsed_time in
      let font_size = 16 in
      let text_x = x + 73 in
      let text_y = y + 38 in
      draw_text_ex f time_str
        (Vector2.create (float_of_int text_x) (float_of_int text_y))
        (float_of_int font_size) 2.0 Color.black;

      let time_str = format_time elapsed_time in
      let font_size = 16 in
      let text_x = x + 70 in
      let text_y = y + 35 in
      draw_text_ex f time_str
        (Vector2.create (float_of_int text_x) (float_of_int text_y))
        (float_of_int font_size) 2.0 Color.white
