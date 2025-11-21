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
      { crop_texture = load_texture "assets/crops/tomato1.png" };
      { crop_texture = load_texture "assets/crops/tomato2.png" };
      { crop_texture = load_texture "assets/crops/tomato3.png" };
      { crop_texture = load_texture "assets/crops/tomato4.png" };
      { crop_texture = load_texture "assets/crops/tomato5.png" };
      { crop_texture = load_texture "assets/crops/wheat1.png" };
      { crop_texture = load_texture "assets/crops/wheat2.png" };
      { crop_texture = load_texture "assets/crops/wheat3.png" };
      { crop_texture = load_texture "assets/crops/wheat4.png" };
      { crop_texture = load_texture "assets/crops/wheat5.png" };
      { crop_texture = load_texture "assets/crops/pumpkin1.png" };
      { crop_texture = load_texture "assets/crops/pumpkin2.png" };
      { crop_texture = load_texture "assets/crops/pumpkin3.png" };
      { crop_texture = load_texture "assets/crops/pumpkin4.png" };
      { crop_texture = load_texture "assets/crops/pumpkin5.png" };
      { crop_texture = load_texture "assets/crops/grape1.png" };
      { crop_texture = load_texture "assets/crops/grape2.png" };
      { crop_texture = load_texture "assets/crops/grape3.png" };
      { crop_texture = load_texture "assets/crops/grape4.png" };
      { crop_texture = load_texture "assets/crops/grape5.png" };
    |]

(* Unload textures *)
let unload_assets () =
  Array.iter (fun frames -> unload_texture frames.crop_texture) !crop_textures

(* Draw Crop *)
let draw_crop (crop : Crop.crop_instance) (x : float) (y : float) =
  let frames = !crop_textures in

  (* Choose texture *)
  let texture =
    match (crop.current_stage, crop.stats.kind) with
    | 0, Strawberry -> frames.(0).crop_texture
    | 1, Strawberry -> frames.(1).crop_texture
    | 2, Strawberry -> frames.(2).crop_texture
    | 3, Strawberry -> frames.(3).crop_texture
    | 4, Strawberry -> frames.(4).crop_texture
    | 0, Tomato -> frames.(5).crop_texture
    | 1, Tomato -> frames.(6).crop_texture
    | 2, Tomato -> frames.(7).crop_texture
    | 3, Tomato -> frames.(8).crop_texture
    | 4, Tomato -> frames.(9).crop_texture
    | 0, Wheat -> frames.(10).crop_texture
    | 1, Wheat -> frames.(11).crop_texture
    | 2, Wheat -> frames.(12).crop_texture
    | 3, Wheat -> frames.(13).crop_texture
    | 4, Wheat -> frames.(14).crop_texture
    | 0, Pumpkin -> frames.(15).crop_texture
    | 1, Pumpkin -> frames.(16).crop_texture
    | 2, Pumpkin -> frames.(17).crop_texture
    | 3, Pumpkin -> frames.(18).crop_texture
    | 4, Pumpkin -> frames.(19).crop_texture
    | 0, Grape -> frames.(20).crop_texture
    | 1, Grape -> frames.(21).crop_texture
    | 2, Grape -> frames.(22).crop_texture
    | 3, Grape -> frames.(23).crop_texture
    | 4, Grape -> frames.(24).crop_texture
    | _, _ -> frames.(0).crop_texture
  in

  (* Draw *)
  draw_texture_ex texture (Vector2.create x y) 0.0 0.20 Color.white
