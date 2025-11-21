(** [load_assets] loads all assets corresponding to crops into VRAM on the GPU *)
val load_assets : unit -> unit

(** [draw_crop crop_instance] draws the texture for [crop_instance] to the screen *)
val draw_crop : Model.Crop.crop_instance -> float -> float -> unit

(** [unload_assets] unloads all assets corresponding to crops from VRAM on the GPU *)
val unload_assets : unit -> unit
