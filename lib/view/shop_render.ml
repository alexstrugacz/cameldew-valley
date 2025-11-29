open Raylib

(* ---------------- Textures ---------------- *)
let shop_texture = ref None
let speech_bubble_texture = ref None
let font = ref None (* custom font *)

(* ---------------- Load Assets ---------------- *)
let load_assets () =
  shop_texture := Some (load_texture "assets/shop/shop.png");
  speech_bubble_texture := Some (load_texture "assets/shop/speech-bubble.png");
  font := Some (load_font "assets/fonts/PressStart2P-Regular.ttf")

(* ---------------- Unload Assets ---------------- *)
let unload_assets () =
  Option.iter unload_texture !shop_texture;
  Option.iter unload_texture !speech_bubble_texture;
  Option.iter unload_font !font

(* ---------------- Draw Shop ---------------- *)
let draw_shop () =
  match !shop_texture with
  | None -> ()
  | Some tex ->
      let x = 150 in
      let y = 50 in
      let pos = Vector2.create (float_of_int x) (float_of_int y) in
      draw_rectangle 0 0 1280 720 (Color.create 0 0 0 100);
      draw_texture_ex tex pos 0.0 0.9 Color.white
