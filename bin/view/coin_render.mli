val load : unit -> unit
(** [load] loads the coin display file*)

val draw_coin : Model.Player.player -> unit
(** [draw_coin player] draws the coin display to the screen with the value of
    the player's currently held coins*)

val unload : unit -> unit
(** [unload] unloads the coin display asset *)
