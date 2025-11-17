open Input_handler
module P = Model.Player
module B = Model.Board
module Crop = Model.Crop

(* Controller *)

let move player direction width height =
  let new_p = P.move_player player direction width height in
  Printf.printf "The player's location is: (%s, %s) " (string_of_int new_p.x)
    (string_of_int new_p.y);
  new_p

let take_action board_width board_height player action =
  match action with
  | Move P.North -> move player P.North board_width board_height
  | Move P.West -> move player P.West board_width board_height
  | Move P.South -> move player P.South board_width board_height
  | Move P.East -> move player P.East board_width board_height
  | Interact ->
      print_endline "handle interact with shop, soil, crop, etc";
      player
  | Select_slot slot ->
      print_endline "select a slot";
      player
  | Toggle_Buy_Sell ->
      print_endline "toggle buy sell";
      player

let handle_actions board_width board_height player action_list =
  List.fold_left (take_action board_width board_height) player action_list

(* Create 12 crops. For now, all are strawberries. *)
let create_initial_crops (num_crops : int) : Crop.crop_instance list =
  List.init 12 (fun i -> Crop.create_crop Crop.Strawberry)

let try_grow_crop (crop : Crop.crop_instance) : Crop.crop_instance =
  Crop.try_grow crop

let try_grow_all_crops (crop_list : Crop.crop_instance list) :
    Crop.crop_instance list =
  List.map try_grow_crop crop_list
