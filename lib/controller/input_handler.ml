module P = Model.Player

type action =
  | Move of P.direction
  | Interact
  | Toggle_Buy_Sell
  | Select_slot of int

(* Raylib will shadow types from our player model, need to assign our player
   model to an alias to avoid shadowing! *)
let check_input () =
  let open Raylib in
  let inputs = ref [] in

  if is_key_pressed Key.W then inputs := Move P.North :: !inputs;
  if is_key_pressed Key.A then inputs := Move P.West :: !inputs;
  if is_key_pressed Key.S then inputs := Move P.South :: !inputs;
  if is_key_pressed Key.D then inputs := Move P.East :: !inputs;

  if is_key_pressed Key.F then inputs := Interact :: !inputs;
  if is_key_pressed Key.Left_shift then inputs := Toggle_Buy_Sell :: !inputs;

  if is_key_pressed Key.One then inputs := Select_slot 0 :: !inputs;
  if is_key_pressed Key.Two then inputs := Select_slot 1 :: !inputs;
  if is_key_pressed Key.Three then inputs := Select_slot 2 :: !inputs;
  if is_key_pressed Key.Four then inputs := Select_slot 3 :: !inputs;
  if is_key_pressed Key.Five then inputs := Select_slot 4 :: !inputs;
  !inputs

let pp_actions_from_inputs = function
  | Move P.North -> "Move North"
  | Move P.West -> "Move West"
  | Move P.South -> "Move South"
  | Move P.East -> "Move East"
  | Interact -> "Interact"
  | Toggle_Buy_Sell -> "Toggle Buy/Sell"
  | Select_slot slot -> Printf.sprintf "Select Slot %d" (slot + 1)

let print_inputs actions =
  List.iter
    (fun action -> print_endline (pp_actions_from_inputs action))
    actions
