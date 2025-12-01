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

(** [interact_with_shop gs] toggles the shop open/closed and pauses/unpauses the
    game accordingly *)
let interact_with_shop gs =
  let new_shop_open = not gs.GS.shop_open in
  let new_phase =
    if new_shop_open then
      (* Opening shop: pause if currently playing *)
      match gs.GS.phase with
      | GS.Playing -> GS.Paused
      | _ -> gs.GS.phase
    else
      (* Closing shop: resume if paused *)
      match gs.GS.phase with
      | GS.Paused -> GS.Playing
      | _ -> gs.GS.phase
  in
  { gs with GS.shop_open = new_shop_open; GS.phase = new_phase }

let interact_with_soil gs tile_x tile_y crop =
  match crop with
  | Some crop ->
      if Crop.is_harvestable crop then (
        let player = gs.GS.player in
        (* Game state after harvesting and selling. *)
        let player_model_after_harvest =
          let player' = P.harvest_and_sell player crop in
          let player_opt'' = P.add_seeds player' crop.stats.kind 3 in
          match player_opt'' with
          | Some player -> player
          | None -> player'
        in
        B.set_tile gs.GS.board tile_x tile_y (B.Soil None);
        { gs with GS.player = player_model_after_harvest }
        (* If the crop is not harvestable, do nothing. *))
      else gs
  | None -> (
      let player' = P.remove_seed gs.GS.player gs.GS.player.selected_slot in
      match player' with
      | Some (player', crop_kind_planted) ->
          let new_crop = Crop.create_crop crop_kind_planted in
          B.set_tile gs.GS.board tile_x tile_y (Soil (Some new_crop));
          gs
      | None -> gs)

let take_action (gs : GS.game_state) (action : Input_handler.action) :
    GS.game_state =
  match (gs.GS.phase, action) with
  | _, Pause -> GS.toggle_pause gs
  | GS.Playing, Move dir -> move gs dir
  | GS.Playing, Interact -> (
      (* Check both the tile the player is standing on and the tile they're
         facing *)
      let player_tile_opt =
        B.get_tile gs.GS.board gs.GS.player.P.x gs.GS.player.P.y
      in
      let tile_x, tile_y, facing_tile_opt =
        B.get_facing_tile gs.GS.board gs.GS.player
      in
      match (player_tile_opt, facing_tile_opt) with
      | Some B.Shop, _ -> interact_with_shop gs
      | _, Some B.Shop -> interact_with_shop gs
      | _, Some (B.Soil (Some crop)) ->
          interact_with_soil gs tile_x tile_y (Some crop)
      | _, Some (B.Soil None) -> interact_with_soil gs tile_x tile_y None
      | _, _ -> gs)
  | GS.Paused, Interact ->
      (* When paused and shop open, allow closing shop by pressing F *)
      interact_with_shop gs
  | GS.Playing, Select_slot i ->
      let new_player = { gs.GS.player with selected_slot = i } in
      { gs with GS.player = new_player }
  | GS.Paused, _ | GS.NotPlaying, _ -> gs

(* Apply a whole list of actions in sequence *)
let handle_actions (gs : GS.game_state) (actions : Input_handler.action list) :
    GS.game_state =
  List.fold_left take_action gs actions

let () = Random.self_init ()

let get_random_crop_type () =
  let i = Random.int 5 in
  match i with
  | 0 -> Crop.Strawberry
  | 1 -> Crop.Wheat
  | 2 -> Crop.Tomato
  | 3 -> Crop.Grape
  | 4 -> Crop.Pumpkin
  | _ -> Crop.Strawberry

(* Create 12 crops. *)
let create_initial_crops (num_crops : int) : Crop.crop_instance list =
  List.init 12 (fun i -> Crop.create_crop (get_random_crop_type ()))

let try_grow_crop (crop : Crop.crop_instance) : Crop.crop_instance =
  Crop.try_grow crop

let try_grow_all_crops (crop_list : Crop.crop_instance list) :
    Crop.crop_instance list =
  List.map try_grow_crop crop_list
