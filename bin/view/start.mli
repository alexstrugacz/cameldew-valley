(** Start screen module for username input *)

(** [load ()] loads the font assets for the start screen *)
val load : unit -> unit

(** [unload ()] unloads the font assets *)
val unload : unit -> unit

(** [get_username ()] displays the start screen and returns the username entered *)
val get_username : unit -> string

