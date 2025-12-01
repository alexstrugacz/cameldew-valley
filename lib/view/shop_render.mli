val load_assets : unit -> unit
(** [load_assets ()] loads all shop-related textures and fonts into VRAM. *)

val draw_shop : bool -> unit
(** [draw_shop shop_is_open] draws the shop interface on the screen. If
    [shop_is_open] is [true] and the shop was previously closed, the speech
    bubble will animate with a zoom-in effect. *)

val unload_assets : unit -> unit
(** [unload_assets ()] unloads all shop-related textures and fonts from VRAM. *)
