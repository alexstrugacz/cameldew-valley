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
  { gs with GS.player = new_p }

(** [interact_with_shop gs] toggles the shop open/closed and pauses/unpauses the
    game accordingly *)
let interact_with_shop gs =
  let new_shop_open = not gs.GS.shop_open in
  let new_phase =
    if new_shop_open then
      (* Opening shop: pause if currently playing *)
      match gs.GS.phase with
      | GS.Playing -> gs.GS.phase
      | _ -> gs.GS.phase
    else
      (* Closing shop: resume if paused *)
      match gs.GS.phase with
      | GS.Paused -> GS.Playing
      | _ -> gs.GS.phase
  in
  { gs with GS.shop_open = new_shop_open; GS.phase = new_phase }

(** [interact_with_soil gs tile_x tile_y crop] handles player interaction with a
    soil tile containing a [crop]

    - If the crop is harvestable, the function: 1. Applies harvesting and
      selling to the player model 2. Attempts to add 3 new seeds of the same
      crop type to the player 3. Clears the soil tile on the board 4. Returns an
      updated game state with the modified player

    - If the crop is not harvestable, the game state is returned unchanged *)
let interact_with_soil gs tile_x tile_y =
  let board = gs.GS.board in
  let player = gs.GS.player in
  let selected_slot = gs.GS.player.selected_slot in
  match B.get_nearest_soil_point tile_x tile_y with
  | None -> gs
  | Some (x, y) -> (
      match B.get_tile board x y with
      | Some (B.Soil None) -> (
          (* Plant a crop *)
          match P.remove_seed player selected_slot with
          | None -> gs
          | Some (player', crop_kind_seed_removed) ->
              let new_crop = Crop.create_crop crop_kind_seed_removed in
              B.set_tile board x y (B.Soil (Some new_crop));
              { gs with GS.player = player' })
      | Some (B.Soil (Some crop)) ->
          if Crop.is_harvestable crop then (
            (* Harvest a crop *)
            let player' = P.harvest_and_sell player crop in
            let player'' =
              match P.add_seeds player' crop.stats.kind 1 with
              | Some p -> p
              | None -> player'
            in
            B.set_tile board x y (B.Soil None);
            { gs with GS.player = player'' })
          else gs
      | Some B.Shop -> gs
      | Some B.Path -> gs
      | None -> gs)

let select_slot_index_crop_type = function
  | 0 -> Crop.Wheat
  | 1 -> Crop.Strawberry
  | 2 -> Crop.Grape
  | 3 -> Crop.Tomato
  | 4 -> Crop.Pumpkin
  | _ -> Crop.Wheat

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
      | _, Some (B.Soil _) -> interact_with_soil gs tile_x tile_y
      | _, _ -> gs)
  | GS.Paused, Interact ->
      (* When paused and shop open, allow closing shop by pressing F *)
      interact_with_shop gs
  | GS.Playing, Select_slot i ->
      if gs.GS.shop_open then
        (* Buying from shop logic *)
        let seed_kind_selected = select_slot_index_crop_type i in
        let coins_to_subtract =
          (Crop.crop_database seed_kind_selected).buy_price
        in
        if gs.GS.player.coins - coins_to_subtract >= 0 then
          let new_player =
            match P.add_seeds gs.GS.player seed_kind_selected 3 with
            | Some p -> p
            | None -> gs.GS.player
          in
          let new_player' = P.remove_coins new_player coins_to_subtract in
          { gs with GS.player = new_player' }
        else gs
      else
        (* Normal inventory swap *)
        let new_player = { gs.GS.player with selected_slot = i } in
        { gs with GS.player = new_player }
  | GS.Paused, Select_slot _ ->
      (* Do nothing while paused *)
      gs
  | GS.Paused, Start ->
      (* Start from paused: reset player stats, reset timer, unpause *)
      {
        gs with
        GS.player = gs.GS.initial_player;
        GS.elapsed_time = 0.0;
        GS.phase = GS.Playing;
        GS.board = B.create_board gs.GS.board_width gs.GS.board_height;
      }
  | GS.Paused, Exit | GS.Playing, Exit | GS.NotPlaying, Exit -> gs
  | GS.Paused, _ | GS.NotPlaying, _ | GS.Playing, Start -> gs

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

let try_grow_crop (crop : Crop.crop_instance) : Crop.crop_instance =
  Crop.try_grow crop

let try_grow_all_crops (crop_list : Crop.crop_instance list) :
    Crop.crop_instance list =
  List.map try_grow_crop crop_list
