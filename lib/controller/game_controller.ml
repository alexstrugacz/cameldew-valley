open Input_handler
module P = Model.Player
module B = Model.Board
module Crop = Model.Crop
module GS = Model.Game_state

(* Controller *)

(* let move player direction width height = let new_p = P.move_player player
   direction width height in Printf.printf "The player's location is: (%s, %s) "
   (string_of_int new_p.x) (string_of_int new_p.y); new_p *)

let move (gs : GS.game_state) (dir : P.direction) : GS.game_state =
  let new_p =
    P.move_player gs.GS.player dir gs.GS.board_width gs.GS.board_height
  in
  Printf.printf "The player's location is: (%s, %s) " (string_of_int new_p.x)
    (string_of_int new_p.y);
  { gs with GS.player = new_p }

let take_action (gs : GS.game_state) (action : Input_handler.action) :
    GS.game_state =
  match (gs.GS.phase, action) with
  | _, Pause -> GS.toggle_pause gs
  | GS.Playing, Move dir -> move gs dir
  | GS.Playing, Interact ->
      (* TODO: interaction logic *)
      gs
  | GS.Playing, Toggle_Buy_Sell ->
      (* TODO: open / close shop *)
      gs
  | GS.Playing, Select_slot i ->
      (* TODO: change selected inventory slot to i *)
      gs
  | GS.Paused, _ | GS.NotPlaying, _ -> gs

(* Apply a whole list of actions in sequence *)
let handle_actions (gs : GS.game_state) (actions : Input_handler.action list) :
    GS.game_state =
  List.fold_left take_action gs actions

(* Create 12 crops. For now, all are strawberries. *)
let create_initial_crops (num_crops : int) : Crop.crop_instance list =
  List.init 12 (fun i -> Crop.create_crop Crop.Strawberry)

let try_grow_crop (crop : Crop.crop_instance) : Crop.crop_instance =
  Crop.try_grow crop

let try_grow_all_crops (crop_list : Crop.crop_instance list) :
    Crop.crop_instance list =
  List.map try_grow_crop crop_list
