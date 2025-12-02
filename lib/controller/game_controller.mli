val handle_actions :
  Model.Game_state.game_state ->
  Input_handler.action list ->
  Model.Game_state.game_state
(** [handle_actions gs actions] returns a new game_state representing all
    [actions] applied to [gs]. *)

val create_initial_crops : int -> Model.Crop.crop_instance list
(** [create_initial_crops num_crops] creates [num_crops] crops at an initial
    growth stage of 0. For now, all are strawberries (but this will change). *)

val try_grow_all_crops :
  Model.Crop.crop_instance list -> Model.Crop.crop_instance list
(** [try_grow_all_crops crop_list] tries to increment the growth stage of each
    crop in [crop_list] by 1 *)

val interact_with_shop :
  Model.Game_state.game_state -> Model.Game_state.game_state
(** [interact_with_shop] toggles the shop open/closed and pauses/unpauses the
    game accordingly*)

val interact_with_soil :
  Model.Game_state.game_state ->
  int ->
  int ->
  Model.Game_state.game_state
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

val create_initial_crops : int -> Model.Crop.crop_instance list
val try_grow_crop : Model.Crop.crop_instance -> Model.Crop.crop_instance

val try_grow_all_crops :
  Model.Crop.crop_instance list -> Model.Crop.crop_instance list
