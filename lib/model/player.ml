(** Player state and inventory management *)

type direction =
  | North
  | South
  | East
  | West

type inventory_slot = {
  seed_type : Crop.crop_kind option; (* None = empty slot *)
  count : int;
}

type player = {
  x : int;
  y : int;
  facing : direction;
  coins : int;
  inventory : inventory_slot array; (* Fixed size: 5 slots *)
  selected_slot : int; (* 0-4 *)
}

(** [create_player x y starting_coins] creates a new player at position (x, y)
*)
let create_player x y starting_coins =
  {
    x;
    y;
    facing = South;
    coins = starting_coins;
    inventory = Array.init 5 (fun _ -> { seed_type = None; count = 0 });
    selected_slot = 0;
  }

(** [forbidden] represents locations the user can't traverse *)
let forbidden =
  [
    (* SHOP AREA*) (460, 0, 765, 55); (* CORNER TREE AREA *) (1095, 0, 1280, 70);
  ]
(* x1, y1, x2, y2 *)

(** [is_blocked (x, y)] returns whether this coordinate is blocked for the user*)
let is_blocked (x, y) =
  List.exists
    (fun (x1, y1, x2, y2) -> x >= x1 && x <= x2 && y >= y1 && y <= y2)
    forbidden

(** [move_player player dir board_width board_height] moves player in the
    selected direction *)
let move_player player dir board_width board_height =
  let new_x, new_y =
    match dir with
    | North -> (player.x, max 0 (player.y - 4))
    | South -> (player.x, min (board_height - 1) (player.y + 4))
    | West -> (max 0 (player.x - 4), player.y)
    | East -> (min (board_width - 1) (player.x + 4), player.y)
  in
  if is_blocked (new_x, new_y) then { player with facing = dir }
  else { player with x = new_x; y = new_y; facing = dir }

(** Map the correct crop kind to its fixed inventory slot *)
let slot_for_crop (kind : Crop.crop_kind) : int =
  match kind with
  | Wheat -> 0
  | Strawberry -> 1
  | Grape -> 2
  | Tomato -> 3
  | Pumpkin -> 4

(** [add_seeds player kind count] adds seeds to the fixed slot for that crop! *)
let add_seeds player kind count =
  let slot_idx = slot_for_crop kind in
  let slot = player.inventory.(slot_idx) in

  (* Update slot *)
  player.inventory.(slot_idx) <-
    { seed_type = Some kind; count = slot.count + count };

  Some player

(** [remove_seed player slot_idx] removes one seed from the given slot;
    primarily for planting*)
let remove_seed player slot_idx =
  if slot_idx < 0 || slot_idx >= Array.length player.inventory then None
  else
    let slot = player.inventory.(slot_idx) in
    match slot.seed_type with
    | None -> None (* Empty slot *)
    | Some kind when slot.count > 0 ->
        player.inventory.(slot_idx) <-
          {
            seed_type = (if slot.count = 1 then None else Some kind);
            count = slot.count - 1;
          };
        Some (player, kind)
    | _ -> None

(** [harvest_and_sell player crop] immediately sells the crop and adds coins *)
let harvest_and_sell player crop =
  let sell_price = crop.Crop.stats.sell_price in
  { player with coins = player.coins + sell_price }

(** [get_current_tile player] returns player's current position *)
let get_current_tile player = (player.x, player.y)

(** [remove_coins player num_coins] returns player with [num_coins] subtracted
    from the current number of coins *)
let remove_coins player num_coins =
  { player with coins = player.coins - num_coins }
