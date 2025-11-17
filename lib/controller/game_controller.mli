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
