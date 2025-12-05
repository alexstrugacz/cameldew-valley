(** Leaderboard rendering module *)

module LB = Model.Leaderboard
open Raylib

let font = ref None
let bg = ref None

let load () =
  font := Some (load_font "assets/fonts/PressStart2P-Regular.ttf");
  bg := Some (load_texture "assets/title/title-bg.png")

let unload () =
  (match !font with
  | Some f -> unload_font f
  | None -> ());
  match !bg with
  | Some t -> unload_texture t
  | None -> ()

(** Helper function to take first n elements from a list *)
let rec take n = function
  | [] -> []
  | h :: t when n > 0 -> h :: take (n - 1) t
  | _ -> []

(** [draw_leaderboard scores] draws the leaderboard with the top scores *)
let draw_leaderboard scores =
  let screen_width = 1280 in
  let screen_height = 720 in

  (* Draw semi-transparent background *)
  (match !bg with
  | Some tex ->
      draw_texture tex 0 0 Color.white;
      draw_rectangle (640 - 500) 132 1000 550 (Color.create 0 0 0 120)
  | None -> ());

  (* Title *)
  let title = "LEADERBOARD" in
  let title_size = 48.0 in
  let title_spacing = 2.0 in

  match !font with
  | None -> ()
  | Some f ->
      let title_size_vec = measure_text_ex f title title_size title_spacing in
      let title_x =
        (float_of_int screen_width -. Vector2.x title_size_vec) /. 2.0
      in
      let title_y = 50.0 in

      (* Draw title with shadow *)
      draw_text_ex f title
        (Vector2.create (title_x +. 3.0) (title_y +. 3.0))
        title_size title_spacing Color.black;
      draw_text_ex f title
        (Vector2.create title_x title_y)
        title_size title_spacing Color.white;

      (* Draw scores *)
      let score_size = 24.0 in
      let score_spacing = 1.0 in
      let start_y = 150.0 in
      let line_height = 50.0 in

      let draw_score_entry rank entry y_pos =
        let rank_str = Printf.sprintf "%d." rank in
        let name_str = entry.LB.username in
        let coins_str = Printf.sprintf "%d coins" entry.LB.coins in

        (* Rank *)
        draw_text_ex f rank_str
          (Vector2.create 200.0 y_pos)
          score_size score_spacing Color.yellow;

        (* Username *)
        draw_text_ex f name_str
          (Vector2.create 300.0 y_pos)
          score_size score_spacing Color.white;

        (* Coins *)
        let coins_size_vec =
          measure_text_ex f coins_str score_size score_spacing
        in
        let coins_x =
          float_of_int screen_width -. Vector2.x coins_size_vec -. 200.0
        in
        draw_text_ex f coins_str
          (Vector2.create coins_x y_pos)
          score_size score_spacing Color.green
      in

      let scores_list = scores in
      let num_scores = min (List.length scores_list) 10 in

      if num_scores = 0 then
        let no_scores = "No scores yet!" in
        let no_scores_size_vec =
          measure_text_ex f no_scores score_size score_spacing
        in
        let no_scores_x =
          (float_of_int screen_width -. Vector2.x no_scores_size_vec) /. 2.0
        in
        draw_text_ex f no_scores
          (Vector2.create no_scores_x (start_y +. 100.0))
          score_size score_spacing Color.gray
      else
        List.iteri
          (fun idx entry ->
            let rank = idx + 1 in
            let y_pos = start_y +. (float_of_int idx *. line_height) in
            draw_score_entry rank entry y_pos)
          (take num_scores scores_list);

      (* Instructions *)
      let instruction = "Press ESC to close" in
      let inst_size = 18.0 in
      let inst_size_vec =
        measure_text_ex f instruction inst_size score_spacing
      in
      let inst_x =
        (float_of_int screen_width -. Vector2.x inst_size_vec) /. 2.0
      in
      let inst_y = float_of_int screen_height -. 100.0 in
      draw_text_ex f instruction
        (Vector2.create inst_x inst_y)
        inst_size score_spacing Color.lightgray
