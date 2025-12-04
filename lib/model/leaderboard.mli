(** Leaderboard database operations using SQLite *)

type score_entry = {
  username : string;
  coins : int;
  timestamp : float;
}

(** [init_db ()] initializes the database and creates the scores table if it doesn't exist *)
val init_db : unit -> unit

(** [save_score username coins] saves a score entry to the database *)
val save_score : string -> int -> unit

(** [get_top_scores limit] retrieves the top [limit] scores from the database, ordered by coins descending *)
val get_top_scores : int -> score_entry list

