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
let get_text_input () =
  let open Raylib in
  let keys =
    [
      (Key.A, 'a');
      (Key.B, 'b');
      (Key.C, 'c');
      (Key.D, 'd');
      (Key.E, 'e');
      (Key.F, 'f');
      (Key.G, 'g');
      (Key.H, 'h');
      (Key.I, 'i');
      (Key.J, 'j');
      (Key.K, 'k');
      (Key.L, 'l');
      (Key.M, 'm');
      (Key.N, 'n');
      (Key.O, 'o');
      (Key.P, 'p');
      (Key.Q, 'q');
      (Key.R, 'r');
      (Key.S, 's');
      (Key.T, 't');
      (Key.U, 'u');
      (Key.V, 'v');
      (Key.W, 'w');
      (Key.X, 'x');
      (Key.Y, 'y');
      (Key.Z, 'z');
      (Key.Zero, '0');
      (Key.One, '1');
      (Key.Two, '2');
      (Key.Three, '3');
      (Key.Four, '4');
      (Key.Five, '5');
      (Key.Six, '6');
      (Key.Seven, '7');
      (Key.Eight, '8');
      (Key.Nine, '9');
    ]
  in
  match List.find_opt (fun (key, _) -> is_key_pressed key) keys with
  | Some (_, ch) -> Some ch
  | None -> None

(** [is_backspace_pressed ()] returns true if backspace was pressed *)
let is_backspace_pressed () =
  let open Raylib in
  is_key_pressed Key.Backspace

let check_input () =
  let open Raylib in
  let inputs = ref [] in

  (* Use is_key_down instead of is_key_pressed for continuous movement *)
  if is_key_down Key.W then inputs := Move P.North :: !inputs;
  if is_key_down Key.A then inputs := Move P.West :: !inputs;
  if is_key_down Key.S then inputs := Move P.South :: !inputs;
  if is_key_down Key.D then inputs := Move P.East :: !inputs;

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
