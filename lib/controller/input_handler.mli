type action =
  | Move of Model.Player.direction
  | Interact
  | Select_slot of int
  | Pause
  | Start
  | Exit

val get_text_input : unit -> char option
(** [get_text_input ()] returns the character that was pressed, or None if no
    valid text input *)

val is_backspace_pressed : unit -> bool
(** [is_backspace_pressed ()] returns true if backspace was pressed *)

val check_input : unit -> action list
(** [check_input] immediately returns a list of each [action] taken by the user
*)

val print_inputs : action list -> unit
(** [print_inputs] prints each [action] from the user input to the console (for
    testing) *)

val pp_actions_from_inputs : action -> string
(** Converts an [action] to a human-readable string. *)
