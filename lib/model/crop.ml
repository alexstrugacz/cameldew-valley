(** Crop system for farm crops *)

type growth_stage = int (* 0 = just planted, max = harvestable *)

type crop_kind =
  | Wheat
  | Strawberry
  | Tomato
  | Grape
  | Pumpkin

type crop_stats = {
  kind : crop_kind;
  growth_rate : float; (* 0.0 - 1.0, probability per tick *)
  max_stage : int; (* Number of stages until harvest *)
  buy_price : int;
  sell_price : int;
}

type crop_instance = {
  stats : crop_stats;
  current_stage : growth_stage;
  id : int;
}

(** Database of all possible crops with their stats *)
let crop_database = function
  | Wheat ->
      {
        kind = Wheat;
        growth_rate = 0.7;
        max_stage = 4;
        buy_price = 5;
        sell_price = 12;
      }
  | Strawberry ->
      {
        kind = Strawberry;
        growth_rate = 0.5;
        max_stage = 4;
        buy_price = 12;
        sell_price = 30;
      }
  | Grape ->
      {
        kind = Grape;
        growth_rate = 0.3;
        max_stage = 4;
        buy_price = 20;
        sell_price = 65;
      }
  | Tomato ->
      {
        kind = Tomato;
        growth_rate = 0.2;
        max_stage = 4;
        buy_price = 35;
        sell_price = 120;
      }
  | Pumpkin ->
      {
        kind = Pumpkin;
        growth_rate = 0.12;
        max_stage = 4;
        buy_price = 50;
        sell_price = 185;
      }

let next_id = ref 0

let generate_id () =
  let id = !next_id in
  incr next_id;
  id

(** [create_crop kind] creates a new crop instance of the given kind *)
let create_crop kind =
  { stats = crop_database kind; current_stage = 0; id = generate_id () }

(** [is_harvestable crop] returns whether the crop is fully grown *)
let is_harvestable crop = crop.current_stage >= crop.stats.max_stage

(** [try_grow crop] attempts to grow the crop by one stage based on growth rate
*)
let try_grow crop =
  if Random.float 1.0 < crop.stats.growth_rate && not (is_harvestable crop) then
    { crop with current_stage = crop.current_stage + 1 }
  else crop
