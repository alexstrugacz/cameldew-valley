open OUnit2
module GS = Model.Game_state
module P = Model.Player

(** [init_test] checks that init: - sets phase to NotPlaying - copies the
    passed-in player and board size - resets elapsed time and shop_open - builds
    a board with the right dimensions. *)
let init_test _ =
  let p = P.create_player 0 0 10 in
  let gs = GS.init 1280 720 p "TestPlayer" in
  assert_equal GS.NotPlaying gs.phase;
  assert_equal p gs.player;
  assert_equal p gs.initial_player;
  assert_equal 1280 gs.board_width;
  assert_equal 720 gs.board_height;
  assert_equal 0.0 gs.elapsed_time;
  assert_bool "shop_open should be false" (gs.shop_open = false);
  assert_equal 720 (Array.length gs.board);
  assert_equal 1280 (Array.length gs.board.(0))

(** [start_playing] checks that start: - transitions NotPlaying -> Playing -
    resets player to initial_player - resets elapsed_time - is a no op if
    already Playing. *)
let start_playing _ =
  let p = P.create_player 0 0 0 in
  let gs0 = GS.init 10 10 p "TestPlayer" in

  (* NotPlaying -> Playing *)
  let gs1 = GS.start gs0 in
  assert_equal GS.Playing gs1.phase;
  assert_equal gs1.initial_player gs1.player;
  assert_equal 0.0 gs1.elapsed_time;

  (* Playing -> Playing (for this one no operations will be conducted) *)
  let gs2 = GS.start gs1 in
  assert_equal GS.Playing gs2.phase;
  assert_equal gs1.player gs2.player;

  (* Paused -> Playing *)
  let gs_paused = GS.toggle_pause gs1 in
  assert_equal GS.Paused gs_paused.phase;

  let gs_resumed = GS.start gs_paused in
  assert_equal GS.Playing gs_resumed.phase;
  assert_equal gs_paused.player gs_resumed.player

(** [stop_playing] checks that stop: - transitions Playing -> NotPlaying - is a
    no op if already NotPlaying. *)
let stop_playing _ =
  let p = P.create_player 0 0 0 in
  let gs0 = GS.init 10 10 p "TestPlayer" in

  (* Playing -> NotPlaying *)
  let gs_play = GS.start gs0 in
  let gs_stop = GS.stop gs_play in
  assert_equal GS.NotPlaying gs_stop.phase;

  (* Paused -> NotPlaying *)
  let gs_play2 = GS.start gs0 in
  let gs_paused = GS.toggle_pause gs_play2 in
  assert_equal GS.Paused gs_paused.phase;
  let gs_stop_from_paused = GS.stop gs_paused in
  assert_equal GS.NotPlaying gs_stop_from_paused.phase;

  (* no ops when already NotPlaying *)
  let gs_stop2 = GS.stop gs_stop in
  assert_equal GS.NotPlaying gs_stop2.phase

(** [toggle_pause] checks that toggle_pause: - does nothing from NotPlaying -
    flips between Playing and Paused if it is playing. *)
let toggle_pause _ =
  let p = P.create_player 0 0 0 in
  let gs0 = GS.init 10 10 p "TestPlayer" in
  let gs_np = GS.toggle_pause gs0 in
  assert_equal GS.NotPlaying gs_np.phase;
  let gs_play = GS.start gs0 in
  let gs_pause = GS.toggle_pause gs_play in
  assert_equal GS.Paused gs_pause.phase;
  let gs_play_again = GS.toggle_pause gs_pause in
  assert_equal GS.Playing gs_play_again.phase

let suite =
  "game_state tests"
  >::: [
         "init_test" >:: init_test;
         "start_playing" >:: start_playing;
         "stop_playing" >:: stop_playing;
         "toggle_pause" >:: toggle_pause;
       ]

let () = run_test_tt_main suite
