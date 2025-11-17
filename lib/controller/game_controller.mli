(** [handle_actions board_width board_height p actions] returns a new player 
representing all [actions] applied to player [p] on a board with [board_height] and [board_width]] *)
val handle_actions : int -> int -> Model.Player.player -> Input_handler.action list -> Model.Player.player

(** [create_initial_crops num_crops] creates [num_crops] crops at an initial growth stage of 0.
For now, all are strawberries (but this will change).  *)
val create_initial_crops : int -> Model.Crop.crop_instance list

(** [try_grow_all_crops crop_list] tries to increment the growth stage of each crop in [crop_list] by 1   *)
val try_grow_all_crops : Model.Crop.crop_instance list -> Model.Crop.crop_instance list