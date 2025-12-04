module P = Model.Player

type action =
  | Move of P.direction
  | Interact
  | Select_slot of int
  | Pause
  | Start
  | Exit

(* Raylib will shadow types from our player model, need to assign our player
   model to an alias to avoid shadowing! *)

(** [get_text_input ()] returns the character that was pressed, or None if no
    valid text input *)
let[@coverage off] get_text_input () =
  let open Raylib in
  let add_char c = Some c in
  if is_key_pressed Key.A then add_char 'a'
  else if is_key_pressed Key.B then add_char 'b'
  else if is_key_pressed Key.C then add_char 'c'
  else if is_key_pressed Key.D then add_char 'd'
  else if is_key_pressed Key.E then add_char 'e'
  else if is_key_pressed Key.F then add_char 'f'
  else if is_key_pressed Key.G then add_char 'g'
  else if is_key_pressed Key.H then add_char 'h'
  else if is_key_pressed Key.I then add_char 'i'
  else if is_key_pressed Key.J then add_char 'j'
  else if is_key_pressed Key.K then add_char 'k'
  else if is_key_pressed Key.L then add_char 'l'
  else if is_key_pressed Key.M then add_char 'm'
  else if is_key_pressed Key.N then add_char 'n'
  else if is_key_pressed Key.O then add_char 'o'
  else if is_key_pressed Key.P then add_char 'p'
  else if is_key_pressed Key.Q then add_char 'q'
  else if is_key_pressed Key.R then add_char 'r'
  else if is_key_pressed Key.S then add_char 's'
  else if is_key_pressed Key.T then add_char 't'
  else if is_key_pressed Key.U then add_char 'u'
  else if is_key_pressed Key.V then add_char 'v'
  else if is_key_pressed Key.W then add_char 'w'
  else if is_key_pressed Key.X then add_char 'x'
  else if is_key_pressed Key.Y then add_char 'y'
  else if is_key_pressed Key.Z then add_char 'z'
  else if is_key_pressed Key.Zero then add_char '0'
  else if is_key_pressed Key.One then add_char '1'
  else if is_key_pressed Key.Two then add_char '2'
  else if is_key_pressed Key.Three then add_char '3'
  else if is_key_pressed Key.Four then add_char '4'
  else if is_key_pressed Key.Five then add_char '5'
  else if is_key_pressed Key.Six then add_char '6'
  else if is_key_pressed Key.Seven then add_char '7'
  else if is_key_pressed Key.Eight then add_char '8'
  else if is_key_pressed Key.Nine then add_char '9'
  else None

(** [is_backspace_pressed ()] returns true if backspace was pressed *)
let[@coverage off] is_backspace_pressed () =
  let open Raylib in
  is_key_pressed Key.Backspace

let[@coverage off] check_input () =
  let open Raylib in
  let inputs = ref [] in

  (* Use is_key_down instead of is_key_pressed for continuous movement *)
  if is_key_down Key.W then inputs := Move P.North :: !inputs;
  if is_key_down Key.A then inputs := Move P.West :: !inputs;
  if is_key_down Key.S then inputs := Move P.South :: !inputs;
  if is_key_down Key.D then inputs := Move P.East :: !inputs;

  if is_key_down Key.Up then inputs := Move P.North :: !inputs;
  if is_key_down Key.Left then inputs := Move P.West :: !inputs;
  if is_key_down Key.Down then inputs := Move P.South :: !inputs;
  if is_key_down Key.Right then inputs := Move P.East :: !inputs;

  (* Other actions can stay as is, since you might not want them repeating *)
  if is_key_pressed Key.F then inputs := Interact :: !inputs;

  if is_key_pressed Key.One then inputs := Select_slot 0 :: !inputs;
  if is_key_pressed Key.Two then inputs := Select_slot 1 :: !inputs;
  if is_key_pressed Key.Three then inputs := Select_slot 2 :: !inputs;
  if is_key_pressed Key.Four then inputs := Select_slot 3 :: !inputs;
  if is_key_pressed Key.Five then inputs := Select_slot 4 :: !inputs;

  if is_key_pressed Key.P then inputs := Pause :: !inputs;
  if is_key_pressed Key.Enter then inputs := Start :: !inputs;
  if is_key_pressed Key.Escape then inputs := Exit :: !inputs;

  !inputs

let pp_actions_from_inputs = function
  | Move P.North -> "Move North"
  | Move P.West -> "Move West"
  | Move P.South -> "Move South"
  | Move P.East -> "Move East"
  | Interact -> "Interact"
  | Select_slot slot -> Printf.sprintf "Select Slot %d" (slot + 1)
  | Pause -> "Pause"
  | Start -> "Start"
  | Exit -> "Exit"

let print_inputs actions =
  List.iter
    (fun action -> print_endline (pp_actions_from_inputs action))
    actions
