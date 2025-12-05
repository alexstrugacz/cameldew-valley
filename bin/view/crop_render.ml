module Crop = Model.Crop
open Raylib

(* Define all crop kinds and their texture file patterns *)
let crop_kinds =
  [|
    (Crop.Strawberry, "assets/crops/strawberry");
    (Crop.Tomato, "assets/crops/tomato");
    (Crop.Wheat, "assets/crops/wheat");
    (Crop.Pumpkin, "assets/crops/pumpkin");
    (Crop.Grape, "assets/crops/grape");
  |]

(* texture table*)
let textures : Texture.t array array ref = ref [||]

let load_assets () =
  textures :=
    Array.map
      (fun (_, base_path) ->
        Array.init 5 (fun stage ->
            let file = Printf.sprintf "%s%d.png" base_path (stage + 1) in
            load_texture file))
      crop_kinds

let unload_assets () = Array.iter (Array.iter unload_texture) !textures

let kind_index kind =
  let rec find i =
    if i >= Array.length crop_kinds then 0
    else
      let k, _ = crop_kinds.(i) in
      if k = kind then i else find (i + 1)
  in
  find 0

(* Draws the crop *)
let draw_crop (crop : Crop.crop_instance) (x : float) (y : float) =
  let kind_i = kind_index crop.stats.kind in
  let stage = min 4 (max 0 crop.current_stage) in
  let texture = !textures.(kind_i).(stage) in

  draw_texture_ex texture (Vector2.create x y) 0.0 0.20 Color.white
