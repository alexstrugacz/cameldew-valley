(** [load_assets] loads all assets corresponding to the shop into VRAM on the GPU *)
val load_assets : unit -> unit

(** [draw_shop] draws the shop UI to the screen when the shop is open *)
val draw_shop : unit -> unit

(** [unload_assets] unloads all assets corresponding to the shop from VRAM on the GPU *)
val unload_assets : unit -> unit
