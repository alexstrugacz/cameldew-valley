(** Leaderboard database operations using SQLite *)

type score_entry = {
  username : string;
  coins : int;
  timestamp : float;
}

let db_path = "leaderboard.db"

(** [init_db ()] initializes the database and creates the scores table if it
    doesn't exist *)
let init_db () =
  let db = Sqlite3.db_open db_path in
  let create_table_sql =
    "CREATE TABLE IF NOT EXISTS scores (\n\
    \      id INTEGER PRIMARY KEY AUTOINCREMENT,\n\
    \      username TEXT NOT NULL,\n\
    \      coins INTEGER NOT NULL,\n\
    \      timestamp REAL NOT NULL\n\
    \    );"
  in
  (match Sqlite3.exec db create_table_sql with
  | Sqlite3.Rc.OK -> ()
  | rc -> Printf.eprintf "Error creating table: %s\n" (Sqlite3.Rc.to_string rc));
  ignore (Sqlite3.db_close db)

(** [save_score username coins] saves a score entry to the database at the end
    of the game*)
let save_score username coins =
  let db = Sqlite3.db_open db_path in
  let timestamp = Unix.time () in
  let insert_sql =
    Printf.sprintf
      "INSERT INTO scores (username, coins, timestamp) VALUES ('%s', %d, %f);"
      (String.escaped username) coins timestamp
  in
  (match Sqlite3.exec db insert_sql with
  | Sqlite3.Rc.OK -> ()
  | rc -> Printf.eprintf "Error inserting score: %s\n" (Sqlite3.Rc.to_string rc));
  ignore (Sqlite3.db_close db)

(** [get_top_scores limit] retrieves the top [limit] scores from the database *)
let get_top_scores limit =
  let db = Sqlite3.db_open db_path in
  let sql =
    Printf.sprintf
      "SELECT username, coins, timestamp FROM scores ORDER BY coins DESC LIMIT \
       %d;"
      limit
  in
  let results = ref [] in
  let callback (row : string array) _ =
    if Array.length row >= 3 then
      let username = row.(0) in
      let coins_str = row.(1) in
      let timestamp_str = row.(2) in
      let coins = int_of_string coins_str in
      let timestamp = float_of_string timestamp_str in
      results := { username; coins; timestamp } :: !results
  in
  (match Sqlite3.exec_not_null db ~cb:callback sql with
  | Sqlite3.Rc.OK -> ()
  | rc -> Printf.eprintf "Error querying scores: %s\n" (Sqlite3.Rc.to_string rc));
  ignore (Sqlite3.db_close db);
  List.rev !results
