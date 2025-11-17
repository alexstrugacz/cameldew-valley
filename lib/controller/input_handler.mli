
type action =
  | Move of Model.Player.direction
  | Interact
  | Toggle_Buy_Sell
  | Select_slot of int

(** [check_input] immediately returns a list of each [action] taken by the user *)
val check_input : unit -> action list

(** [print_inputs] prints each [action] from the user input to the console (for testing) *)
val print_inputs : action list -> unit
