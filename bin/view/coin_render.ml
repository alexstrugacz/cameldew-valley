module P = Model.Player
open Raylib

let coin_texture = ref None
let scale = 0.23
let font = ref None

let load () =
  coin_texture := Some (load_texture "assets/display/coin-display.png");
  font := Some (load_font "assets/fonts/PressStart2P-Regular.ttf")

let unload () =
  begin
    (match !coin_texture with
    | Some t -> unload_texture t
    | None -> ());

    match !font with
    | Some f -> unload_font f
    | None -> ()
  end

let draw_coin (player : P.player) =
  match !coin_texture with
  | None -> ()
  | Some tex -> (
      let x = 830 in
      let y = 10 in
      let pos = Vector2.create (float_of_int x) (float_of_int y) in
      draw_texture_ex tex pos 0.0 scale Color.white;

      let coin_str = string_of_int player.coins in
      let font_size = 21.0 in
      let spacing = 1.0 in

      (* Dimensions of the coin display box *)
      let box_width = float_of_int 50 *. scale in
      let box_height = float_of_int 30 *. scale in

      match !font with
      | Some f ->
          let text_size = measure_text_ex f coin_str font_size spacing in
          let text_w = Vector2.x text_size in
          let text_h = Vector2.y text_size in

          (* Center inside the box *)
          let centered_x = float_of_int 947 +. ((box_width -. text_w) /. 2.0) in
          let centered_y = float_of_int 44 +. ((box_height -. text_h) /. 2.0) in

          draw_text_ex f coin_str
            (Vector2.create (centered_x +. 3.0) (centered_y +. 3.0))
            font_size spacing Color.black;

          draw_text_ex f coin_str
            (Vector2.create centered_x centered_y)
            font_size spacing Color.white
      | None ->
          (* fallback in case no font *)
          let tw = float_of_int (measure_text coin_str 28) in
          let th = 28.0 in
          let centered_x = float_of_int x +. ((box_width -. tw) /. 2.0) in
          let centered_y = float_of_int y +. ((box_height -. th) /. 2.0) in
          draw_text coin_str (int_of_float centered_x) (int_of_float centered_y)
            28 Color.white)
