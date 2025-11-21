open Raylib

let strawberry_texture = ref None
let strawberry_texture2 = ref None

let load_assets () =
  strawberry_texture :=
    Some (load_texture "assets/inventory/strawberry-inv.png");
  strawberry_texture2 :=
    Some (load_texture "assets/inventory/strawberry-inv.png")

let unload_assets () = Option.iter unload_texture !strawberry_texture

let get tex_ref =
  match !tex_ref with
  | Some t -> t
  | None -> failwith "Inventory texture used before loading assets"

let draw_inventory () =
  let base_x = 20 in
  let base_y = 20 in

  (* Draw the strawberry at 0.30 scale *)
  draw_texture_ex (get strawberry_texture)
    (Vector2.create (float_of_int base_x) (float_of_int base_y))
    0.0 0.16 Color.white;
  draw_texture_ex (get strawberry_texture2)
    (Vector2.create (float_of_int (base_x + 85)) (float_of_int base_y))
    0.0 0.16 Color.white
