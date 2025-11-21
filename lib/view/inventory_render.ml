module P = Model.Player
open Raylib

(* ---------------- Textures ---------------- *)
let strawberry_texture = ref None
let tomato_texture = ref None
let pumpkin_texture = ref None
let grape_texture = ref None
let wheat_texture = ref None

(* Selected versions *)
let strawberry_sel_texture = ref None
let tomato_sel_texture = ref None
let pumpkin_sel_texture = ref None
let grape_sel_texture = ref None
let wheat_sel_texture = ref None

(* ---------------- Font ---------------- *)
let inventory_font = ref None

(* ---------------- Animation ---------------- *)
let selection_offset = ref 0.0
let prev_selected_slot = ref 0

(* ---------------- Load Assets ---------------- *)
let load_assets () =
  (* Textures *)
  strawberry_texture :=
    Some (load_texture "assets/inventory/strawberry-inv.png");
  tomato_texture := Some (load_texture "assets/inventory/tomato-inv.png");
  pumpkin_texture := Some (load_texture "assets/inventory/pumpkin-inv.png");
  grape_texture := Some (load_texture "assets/inventory/grape-inv.png");
  wheat_texture := Some (load_texture "assets/inventory/wheat-inv.png");

  strawberry_sel_texture :=
    Some (load_texture "assets/inventory/strawberry-inv-selected.png");
  tomato_sel_texture :=
    Some (load_texture "assets/inventory/tomato-inv-selected.png");
  pumpkin_sel_texture :=
    Some (load_texture "assets/inventory/pumpkin-inv-selected.png");
  grape_sel_texture :=
    Some (load_texture "assets/inventory/grape-inv-selected.png");
  wheat_sel_texture :=
    Some (load_texture "assets/inventory/wheat-inv-selected.png");

  (* Font *)
  inventory_font := Some (load_font "assets/fonts/PressStart2P-Regular.ttf")

(* ---------------- Unload Assets ---------------- *)
let unload_assets () =
  Option.iter unload_texture !strawberry_texture;
  Option.iter unload_texture !tomato_texture;
  Option.iter unload_texture !pumpkin_texture;
  Option.iter unload_texture !grape_texture;
  Option.iter unload_texture !wheat_texture;

  Option.iter unload_texture !strawberry_sel_texture;
  Option.iter unload_texture !tomato_sel_texture;
  Option.iter unload_texture !pumpkin_sel_texture;
  Option.iter unload_texture !grape_sel_texture;
  Option.iter unload_texture !wheat_sel_texture;

  Option.iter unload_font !inventory_font

(* ---------------- Helpers ---------------- *)
let get tex_ref =
  match !tex_ref with
  | Some t -> t
  | None -> failwith "Inventory texture used before loading assets"

let texture_for_slot slot_idx selected_idx (default_tex, sel_tex) =
  if slot_idx = selected_idx then get sel_tex else get default_tex

(* Draw text centered at x,y *)
let draw_text_centered font text x y font_size spacing color =
  let text_w = measure_text text font_size in
  let text_h = font_size in
  let text_x = x - (text_w / 2) in
  let text_y = y - (text_h / 2) in
  draw_text_ex font text
    (Vector2.create (float_of_int text_x) (float_of_int text_y))
    (float_of_int font_size) spacing color

(* ---------------- Draw Inventory ---------------- *)
let draw_inventory (player : P.player) =
  let base_x = 40 in
  let base_y = 10 in
  let spacing = 85 in
  let scale = 0.16 in
  let max_offset = 12 in

  (* Animate selection *)
  if player.selected_slot <> !prev_selected_slot then (
    selection_offset := float_of_int max_offset;
    prev_selected_slot := player.selected_slot);

  if !selection_offset > 0.0 then selection_offset := !selection_offset -. 1.2;
  if !selection_offset < 0.0 then selection_offset := 0.0;

  let font =
    match !inventory_font with
    | Some f -> f
    | None -> failwith "Font not loaded"
  in
  let font_size = 14 in

  (* Draw slot *)
  let draw_slot idx tex slot_info =
    let x = base_x + (spacing * idx) in
    let y =
      base_y
      + if idx = player.selected_slot then int_of_float !selection_offset else 0
    in

    (* Draw slot texture *)
    draw_texture_ex tex
      (Vector2.create (float_of_int x) (float_of_int y))
      0.0 scale Color.white;

    (* Draw keybind number above slot *)
    draw_text_centered font
      (string_of_int (idx + 1))
      (x + (spacing / 2) - 30)
      (y + 15) font_size 1.0 Color.black;

    (* Draw seed count at bottom-right corner of slot *)
    let count =
      match slot_info.P.seed_type with
      | None -> 0
      | Some _ -> slot_info.P.count
    in
    (* DROP SHADOW part *)
    draw_text_centered font (string_of_int count)
      (x + spacing - 19)
      (y + 80) (font_size + 5) 1.0 Color.black;
    (* Actual white part *)
    draw_text_centered font (string_of_int count)
      (x + spacing - 21) (* offset near right edge *)
      (y + 78) (* offset below texture *)
      (font_size + 5) 1.0 Color.white
  in

  (* Draw all 5 inventory slots *)
  Array.iteri
    (fun idx slot ->
      let tex =
        match idx with
        | 0 ->
            texture_for_slot 0 player.selected_slot
              (wheat_texture, wheat_sel_texture)
        | 1 ->
            texture_for_slot 1 player.selected_slot
              (strawberry_texture, strawberry_sel_texture)
        | 2 ->
            texture_for_slot 2 player.selected_slot
              (grape_texture, grape_sel_texture)
        | 3 ->
            texture_for_slot 3 player.selected_slot
              (tomato_texture, tomato_sel_texture)
        | 4 ->
            texture_for_slot 4 player.selected_slot
              (pumpkin_texture, pumpkin_sel_texture)
        | _ -> failwith "Invalid slot index"
      in
      draw_slot idx tex slot)
    player.P.inventory
