(** Leaderboard rendering module *)

(** [load ()] loads the font assets for the leaderboard *)
val load : unit -> unit

(** [unload ()] unloads the font assets *)
val unload : unit -> unit

(** [draw_leaderboard scores] draws the leaderboard with the top scores *)
val draw_leaderboard : Model.Leaderboard.score_entry list -> unit

