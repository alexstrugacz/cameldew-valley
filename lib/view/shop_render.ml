open Raylib

(* ---------------- Textures ---------------- *)
let shop_texture = ref None
let speech_bubble_texture = ref None

(* ---------------- Load Assets ---------------- *)
let load_assets () =
  shop_texture := Some (load_texture "assets/shop/shop.png");
  speech_bubble_texture := Some (load_texture "assets/shop/speech-bubble.png")

(* ---------------- Unload Assets ---------------- *)
let unload_assets () =
  Option.iter unload_texture !shop_texture;
  Option.iter unload_texture !speech_bubble_texture

(* ---------------- Draw Shop ---------------- *)
let draw_shop () =
  match !shop_texture with
  | None -> ()
  | Some tex ->
      let x = 80 in
      let y = 10 in
      let pos = Vector2.create (float_of_int x) (float_of_int y) in
      draw_texture_ex tex pos 0.0 1.0 Color.white
