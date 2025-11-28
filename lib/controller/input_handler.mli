type action =
  | Move of Model.Player.direction
  | Interact
  | Select_slot of int
  | Pause

val check_input : unit -> action list
(** [check_input] immediately returns a list of each [action] taken by the user
*)

val print_inputs : action list -> unit
(** [print_inputs] prints each [action] from the user input to the console (for
    testing) *)
