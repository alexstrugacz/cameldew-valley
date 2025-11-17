module Crop = Model.Crop
open Raylib

(* Player textures per direction *)
type crop_frames = { crop_texture : Texture.t }

let crop_textures = ref [||]

(* Animation state *)
let animation_timer = ref 0.0
let animation_speed = 0.16
let current_frame = ref 0

(* Load textures *)
let load_assets () =
  crop_textures :=
    [|
      { crop_texture = load_texture "assets/crops/strawberry1.png" };
      { crop_texture = load_texture "assets/crops/strawberry2.png" };
      { crop_texture = load_texture "assets/crops/strawberry3.png" };
      { crop_texture = load_texture "assets/crops/strawberry4.png" };
      { crop_texture = load_texture "assets/crops/strawberry5.png" };
    |]

(* Unload textures *)
let unload_assets () =
  Array.iter (fun frames -> unload_texture frames.crop_texture) !crop_textures

(* Draw Crop *)
let draw_crop (crop : Crop.crop_instance) (x : float) (y : float) =
  let frames = !crop_textures in

  (* Choose texture *)
  let texture =
    match crop.current_stage with
    | 0 -> frames.(0).crop_texture
    | 1 -> frames.(1).crop_texture
    | 2 -> frames.(2).crop_texture
    | 3 -> frames.(3).crop_texture
    | 4 -> frames.(4).crop_texture
    | _ -> frames.(0).crop_texture
  in

  (* Draw *)
  draw_texture_ex texture (Vector2.create x y) 0.0 0.35 Color.white
