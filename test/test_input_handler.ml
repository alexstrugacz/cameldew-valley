open OUnit2
module IH = Controller.Input_handler
module P = Model.Player

(** [test_pp_move_north] checks that Move North is pretty-printed correctly. *)
let test_pp_move_north _ =
  let s = IH.pp_actions_from_inputs (IH.Move P.North) in
  assert_equal "Move North" s

(** [test_pp_move_west] checks that Move West is pretty-printed correctly. *)
let test_pp_move_west _ =
  let s = IH.pp_actions_from_inputs (IH.Move P.West) in
  assert_equal "Move West" s

(** [test_pp_move_south] checks that Move South is pretty-printed correctly. *)
let test_pp_move_south _ =
  let s = IH.pp_actions_from_inputs (IH.Move P.South) in
  assert_equal "Move South" s

(** [test_pp_move_east] checks that Move East is pretty-printed correctly. *)
let test_pp_move_east _ =
  let s = IH.pp_actions_from_inputs (IH.Move P.East) in
  assert_equal "Move East" s

(** [test_pp_interact] checks that Interact is pretty-printed correctly. *)
let test_pp_interact _ =
  let s = IH.pp_actions_from_inputs IH.Interact in
  assert_equal "Interact" s

(** [test_pp_select_slot_0] checks that Select_slot 0 prints as "Select Slot 1".
*)
let test_pp_select_slot_0 _ =
  let s = IH.pp_actions_from_inputs (IH.Select_slot 0) in
  assert_equal "Select Slot 1" s

(** [test_pp_select_slot_3] checks that Select_slot 3 prints as "Select Slot 4".
*)
let test_pp_select_slot_3 _ =
  let s = IH.pp_actions_from_inputs (IH.Select_slot 3) in
  assert_equal "Select Slot 4" s

(** [test_pp_pause] checks that Pause is pretty-printed correctly. *)
let test_pp_pause _ =
  let s = IH.pp_actions_from_inputs IH.Pause in
  assert_equal "Pause" s

(** [test_print_inputs_empty_does_not_raise] checks that printing an empty list
    is a no-op that does not raise. *)
let test_print_inputs_empty_does_not_raise _ =
  let ok =
    try
      IH.print_inputs [];
      true
    with _ -> false
  in
  assert_bool "print_inputs [] should not raise" ok

(** [test_print_inputs_all_constructors_does_not_raise] checks that
    [print_inputs] can handle a list containing every action constructor without
    raising. *)
let test_print_inputs_all_constructors_does_not_raise _ =
  let actions =
    [
      IH.Move P.North;
      IH.Move P.South;
      IH.Move P.East;
      IH.Move P.West;
      IH.Interact;
      IH.Select_slot 0;
      IH.Select_slot 4;
      IH.Pause;
    ]
  in
  let ok =
    try
      IH.print_inputs actions;
      true
    with _ -> false
  in
  assert_bool "print_inputs actions shldnt raise err" ok

(** [test_pp_start] checks that Start is pretty printed correctly *)
let test_pp_start _ =
  let s = IH.pp_actions_from_inputs IH.Start in
  assert_equal "Start" s

(** [test_pp_exit] checks that Exit is pretty printed correctly. *)
let test_pp_exit _ =
  let s = IH.pp_actions_from_inputs IH.Exit in
  assert_equal "Exit" s

let suite =
  "input_handler tests"
  >::: [
         "pp_move_north" >:: test_pp_move_north;
         "pp_move_west" >:: test_pp_move_west;
         "pp_move_south" >:: test_pp_move_south;
         "pp_move_east" >:: test_pp_move_east;
         "pp_interact" >:: test_pp_interact;
         "pp_select_slot_0" >:: test_pp_select_slot_0;
         "pp_select_slot_3" >:: test_pp_select_slot_3;
         "pp_pause" >:: test_pp_pause;
         "print_inputs_empty_does_not_raise"
         >:: test_print_inputs_empty_does_not_raise;
         "print_inputs_all_constructors_does_not_raise"
         >:: test_print_inputs_all_constructors_does_not_raise;
         "test_pp_start" >:: test_pp_start;
         "test_pp_exit" >:: test_pp_exit;
       ]

let () = run_test_tt_main suite
