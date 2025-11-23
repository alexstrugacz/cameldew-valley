(** Crop system for farm crops *)

(** Type representing the growth stage of a crop. *)
type growth_stage = int

(** Type representing different kinds of crops *)
type crop_kind =
  | Wheat
  | Strawberry
  | Tomato
  | Grape
  | Pumpkin

(** Type representing the static statistics for a crop kind *)
type crop_stats = {
  kind : crop_kind;
  growth_rate : float;
  max_stage : int;
  buy_price : int; 
  sell_price : int;
}

(** Type representing an individual planted crop instance *)
type crop_instance = {
  stats : crop_stats;
  current_stage : growth_stage;
  id : int;
}

(** [crop_database kind] returns the crop statistics for the given crop kind *)
val crop_database : crop_kind -> crop_stats

(** [create_crop kind] creates a new crop instance of the given kind at 
    growth stage 0 with a unique ID *)
val create_crop : crop_kind -> crop_instance

(** [is_harvestable crop] returns [true] if the crop is fully grown and 
    ready to harvest, [false] otherwise *)
val is_harvestable : crop_instance -> bool

(** [try_grow crop] attempts to grow the crop by one stage  *)
val try_grow : crop_instance -> crop_instance