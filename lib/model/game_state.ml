module P = Player
module B = Board

type phase =
  | Playing
  | NotPlaying
  | Paused

type game_state = {
  phase : phase;
  player : P.player;
  initial_player : P.player;
  board_width : int;
  board_height : int;
  board : B.board;
}

let init board_width board_height player =
  {
    phase = NotPlaying;
    player;
    initial_player = player;
    board_width;
    board_height;
    board = B.create_board board_width board_height;
  }

let start game_state =
  match game_state.phase with
  | Playing -> game_state
  | NotPlaying ->
      { game_state with phase = Playing; player = game_state.initial_player }
  | Paused -> { game_state with phase = Playing }

let stop game_state =
  match game_state.phase with
  | NotPlaying -> game_state
  | Playing -> { game_state with phase = NotPlaying }
  | Paused -> { game_state with phase = NotPlaying }

let toggle_pause game_state =
  match game_state.phase with
  | Playing -> { game_state with phase = Paused }
  | Paused -> { game_state with phase = Playing }
  | NotPlaying -> game_state
