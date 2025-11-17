module P = Model.Player
open Raylib

(* Player textures per direction *)
type player_frames = {
  idle : Texture.t;
  walk : Texture.t array;
}

let player_textures = ref [||]

(* Animation state *)
let animation_timer = ref 0.0
let animation_speed = 0.16
let current_frame = ref 0

(* Load textures *)
let load_assets () =
  player_textures :=
    [|
      {
        idle = load_texture "assets/player/back-idle.png";
        walk =
          [|
            load_texture "assets/player/back-walk-left1.png";
            load_texture "assets/player/back-walk-left2.png";
            load_texture "assets/player/back-walk-left1.png";
            load_texture "assets/player/back-idle.png";
            load_texture "assets/player/back-walk-right1.png";
            load_texture "assets/player/back-walk-right2.png";
            load_texture "assets/player/back-walk-right1.png";
            load_texture "assets/player/back-idle.png";
          |];
      };
      {
        idle = load_texture "assets/player/front-idle.png";
        walk =
          [|
            load_texture "assets/player/front-walk-left1.png";
            load_texture "assets/player/front-walk-left2.png";
            load_texture "assets/player/front-walk-left1.png";
            load_texture "assets/player/front-idle.png";
            load_texture "assets/player/front-walk-right1.png";
            load_texture "assets/player/front-walk-right2.png";
            load_texture "assets/player/front-walk-right1.png";
            load_texture "assets/player/front-idle.png";
          |];
      };
      {
        idle = load_texture "assets/player/right-idle.png";
        walk =
          [|
            load_texture "assets/player/right-walk-left1.png";
            load_texture "assets/player/right-walk-left2.png";
            load_texture "assets/player/right-idle.png";
            load_texture "assets/player/right-walk-right2.png";
            load_texture "assets/player/right-walk-right1.png";
            load_texture "assets/player/right-idle.png";
          |];
      };
      {
        idle = load_texture "assets/player/left-idle.png";
        walk =
          [|
            load_texture "assets/player/left-walk-left1.png";
            load_texture "assets/player/left-walk-left2.png";
            load_texture "assets/player/left-idle.png";
            load_texture "assets/player/left-walk-right2.png";
            load_texture "assets/player/left-walk-right1.png";
            load_texture "assets/player/left-idle.png";
          |];
      };
    |]

(* Unload textures *)
let unload_assets () =
  Array.iter
    (fun frames ->
      unload_texture frames.idle;
      Array.iter unload_texture frames.walk)
    !player_textures

(* Draw player *)
let draw_player (player : P.player) (delta_time : float) (moving : bool) =
  (* Get direction index *)
  let dir_index =
    match player.facing with
    | P.North -> 0
    | P.South -> 1
    | P.East -> 2
    | P.West -> 3
  in

  let frames = !player_textures.(dir_index) in

  (* Update animation timer only if moving *)
  if moving then begin
    animation_timer := !animation_timer +. delta_time;
    if !animation_timer >= animation_speed then begin
      current_frame := (!current_frame + 1) mod Array.length frames.walk;
      animation_timer := 0.0
    end
  end
  else current_frame := 0;

  (* Choose texture *)
  let tex = if moving then frames.walk.(!current_frame) else frames.idle in

  (* Draw *)
  draw_texture_ex tex
    (Vector2.create (float_of_int player.x) (float_of_int player.y))
    0.0 0.35 Color.white
