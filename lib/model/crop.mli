(** Crop system for farm crops *)

type growth_stage = int
(** Type representing the growth stage of a crop. *)

(** Type representing different kinds of crops *)
type crop_kind =
  | Wheat
  | Strawberry
  | Tomato
  | Grape
  | Pumpkin

type crop_stats = {
  kind : crop_kind;
  growth_rate : float;
  max_stage : int;
  buy_price : int;
  sell_price : int;
}
(** Type representing the static statistics for a crop kind *)

type crop_instance = {
  stats : crop_stats;
  current_stage : growth_stage;
  id : int;
}
(** Type representing an individual planted crop instance *)

val crop_database : crop_kind -> crop_stats
(** [crop_database kind] returns the crop statistics for the given crop kind *)

val create_crop : crop_kind -> crop_instance
(** [create_crop kind] creates a new crop instance of the given kind at growth
    stage 0 with a unique ID *)

val is_harvestable : crop_instance -> bool
(** [is_harvestable crop] returns [true] if the crop is fully grown and ready to
    harvest, [false] otherwise *)

val try_grow : crop_instance -> crop_instance
(** [try_grow crop] attempts to grow the crop by one stage *)
