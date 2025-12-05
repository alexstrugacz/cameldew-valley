val handle_actions :
  Model.Game_state.game_state ->
  Input_handler.action list ->
  Model.Game_state.game_state
(** [handle_actions gs actions] returns a new game_state representing all
    [actions] applied to [gs]. *)

val try_grow_all_crops :
  Model.Crop.crop_instance list -> Model.Crop.crop_instance list
(** [try_grow_all_crops crop_list] tries to increment the growth stage of each
    crop in [crop_list] by 1 *)

val interact_with_shop :
  Model.Game_state.game_state -> Model.Game_state.game_state
(** [interact_with_shop] toggles the shop open/closed and pauses/unpauses the
    game accordingly*)

val interact_with_soil :
  Model.Game_state.game_state -> int -> int -> Model.Game_state.game_state
(** [interact_with_soil gs x y crop] processes an interaction with a soil tile
    at coordinates [(x, y)] that contains [crop].

    If the crop is harvestable, the function:
    - harvests and sells it,
    - awards the player 3 seeds of the same crop kind,
    - clears the soil tile,
    - and returns an updated game state.

    If the crop is not harvestable, the game state is returned unchanged. *)

val take_action :
  Model.Game_state.game_state ->
  Input_handler.action ->
  Model.Game_state.game_state
(** [take_action state action] applies a player's [action] to the current
    [state] of the game and returns the resulting updated state.

    The output may change player position, interact with objects, place or
    harvest crops, update inventory, or trigger other state-transition logic
    depending on the given [action]. *)

val try_grow_crop : Model.Crop.crop_instance -> Model.Crop.crop_instance
(** [try_grow_crop crop] returns an updated crop instance after attempting to
    advance its growth, delegating to [Crop.try_grow]

    If [crop] is eligible to grow , its growth stage is incremented and
    otherwise it is returned unchanged. *)

val select_slot_index_crop_type : int -> Model.Crop.crop_kind
(** [select_slot_index_crop_type i] maps a hotbar or inventory slot index [i] to
    the corresponding crop kind used for shop purchases or UI selection.

    The mapping is:
    - 0 ↦ [Crop.Wheat]
    - 1 ↦ [Crop.Strawberry]
    - 2 ↦ [Crop.Grape]
    - 3 ↦ [Crop.Tomato]
    - 4 ↦ [Crop.Pumpkin] *)

val get_random_crop_type : unit -> Model.Crop.crop_kind
(** [get_random_crop_type ()] returns a random crop kind chosen uniformly
    from the set {[Crop.Strawberry; Crop.Wheat; Crop.Tomato; Crop.Grape; 
    Crop.Pumpkin]}.*)
