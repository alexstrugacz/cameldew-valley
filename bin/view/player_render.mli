(** [unload_assets] unloads all assets corresponding to the player from VRAM on the GPU *)
val unload_assets : unit -> unit

(** [draw_inventory player t moving] draws the player [player] with its corresponding textures to the screen. 
The player texture drawn depends on the time [t] and if the player is moving [moving]. *)
val draw_player : Model.Player.player -> float -> bool -> unit

(** [load_assets] loads all assets corresponding to the player into VRAM on the GPU *)
val load_assets : unit -> unit