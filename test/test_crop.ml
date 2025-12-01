open OUnit2
module Crop = Model.Crop

(** [test_create_crop_init] checks that a new crop starts at stage 0 and has the
    correct kind in its stats. *)
let test_create_crop_init _ =
  let c = Crop.create_crop Crop.Wheat in
  assert_equal 0 c.current_stage;
  assert_equal Crop.Wheat c.stats.kind

(** [harvest_only_when_max] checks that a crop becomes harvestable exactly when
    its current_stage = max_stage, and not before. *)
let harvest_only_when_max _ =
  let c = Crop.create_crop Crop.Strawberry in
  let max_stage = c.stats.max_stage in
  let c_not_harvestable = { c with current_stage = max_stage - 1 } in
  assert_bool "should not be harvestable b/c not fully grown"
    (not (Crop.is_harvestable c_not_harvestable));
  let c_max = { c with current_stage = max_stage } in
  assert_bool "should be harvestable (fully grown)" (Crop.is_harvestable c_max)

(** [can't_grow_past_max] checks that try_grow never pushes a crop's stage past
    its max_stage. *)
let can't_grow_past_max _ =
  let c0 = Crop.create_crop Crop.Grape in
  let max_stage = c0.stats.max_stage in
  let c1 = Crop.try_grow c0 in
  assert_bool "stage should not decrease" (c1.current_stage >= c0.current_stage);
  assert_bool "stage should not exceed max" (c1.current_stage <= max_stage)

(** [growing_when_max_does_nun] checks that a fully grown crop (already
    harvestable) will not grow further. *)
let growing_when_max_does_nun _ =
  let c = Crop.create_crop Crop.Pumpkin in
  let max_stage = c.stats.max_stage in
  let c_full = { c with current_stage = max_stage } in
  let c_after = Crop.try_grow c_full in
  assert_equal max_stage c_after.current_stage

(** [each_crop_unique] checks that two separately created crops have different
    ids. *)
let each_crop_unique _ =
  let c1 = Crop.create_crop Crop.Wheat in
  let c2 = Crop.create_crop Crop.Wheat in
  assert_bool "IDs should differ for different crops" (c1.id <> c2.id)

(** [try_grow_acc_works] checks that try_grow's if-branch actually executes.*)
let try_grow_acc_works _ =
  let c = Crop.create_crop Crop.Wheat in
  let c_grow = { c with stats = { c.stats with growth_rate = 1.0 } } in
  let max_stage = c_grow.stats.max_stage in
  let c_before = { c_grow with current_stage = max_stage - 1 } in
  let c_after = Crop.try_grow c_before in
  assert_equal (c_before.current_stage + 1) c_after.current_stage

let suite =
  "crop tests"
  >::: [
         "create_crop_initial" >:: test_create_crop_init;
         "harvest_only_when_max" >:: harvest_only_when_max;
         "can't_grow_past_max" >:: can't_grow_past_max;
         "growing_when_max_does_nun" >:: growing_when_max_does_nun;
         "each_crop_unique" >:: each_crop_unique;
         "try_grow_acc_works" >:: try_grow_acc_works;
       ]

let () = run_test_tt_main suite
