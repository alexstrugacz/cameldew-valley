module C = Model.Crop
open Raylib

(* ---------------- Textures & Fonts ---------------- *)
let shop_texture = ref None
let speech_bubble_texture = ref None
let font = ref None
let desc_font = ref None

(* ---------------- Random Messages ---------------- *)
let messages =
  [|
    "Welcome, farmer!";
    "So many choices...";
    "Buy some seeds!";
    "idk man";
    "OCAML O_O";
    "who is jiwon";
    "I love grapes :";
    "CS3110 x_x";
    "What a nice day!";
    "I love stardew";
    "Cobblestone Chi!!";
  |]

let current_message = ref messages.(0)

(* ---------------- Typewriter State ---------------- *)
let message_index = ref 0 (* how many chars are shown *)
let typing_speed = 25.0 (* chars per second *)
let typing_accumulator = ref 0.0 (* accumulate time for typewriter *)

(* ---------------- Load Assets ---------------- *)
let load_assets () =
  shop_texture := Some (load_texture "assets/shop/shop.png");
  speech_bubble_texture := Some (load_texture "assets/shop/speech-bubble.png");
  font := Some (load_font "assets/fonts/PressStart2P-Regular.ttf");
  desc_font := Some (load_font "assets/fonts/Micro5-Regular.ttf")

(* ---------------- Unload Assets ---------------- *)
let unload_assets () =
  Option.iter unload_texture !shop_texture;
  Option.iter unload_texture !speech_bubble_texture;
  Option.iter unload_font !font;
  Option.iter unload_font !desc_font

(* ---------------- Animation State ---------------- *)
let target_scale = 0.8
let shop_opened_last_frame = ref false

(* ---------------- Draw Shop ---------------- *)
let draw_shop shop_is_open =
  (* Reset animation and pick a new message if shop just opened *)
  if shop_is_open && not !shop_opened_last_frame then begin
    let idx = Random.int (Array.length messages) in
    current_message := messages.(idx);
    message_index := 0;
    typing_accumulator := 0.0
  end;
  shop_opened_last_frame := shop_is_open;

  match (!shop_texture, !speech_bubble_texture) with
  | Some shop_tex, Some bubble_tex when shop_is_open -> (
      (* Background overlay *)
      draw_rectangle 0 0 1280 720 (Color.create 0 0 0 100);

      (* Draw shop *)
      draw_texture_ex shop_tex (Vector2.create 150.0 50.0) 0.0 0.9 Color.white;

      (* Draw speech bubble *)
      draw_texture_ex bubble_tex
        (Vector2.create 360.0 160.0)
        0.0 0.8 Color.white;

      (* Draw text and crop info *)
      match (!font, !desc_font) with
      | Some f, Some fo ->
          let cream = Color.create 255 244 214 255 in

          (* PURCHASE KEY ICONS*)
          draw_text_ex f "1" (Vector2.create 301.0 396.0) 11.0 1.0 Color.black;
          draw_text_ex f "1" (Vector2.create 299.0 394.0) 11.0 1.0 Color.white;
          draw_text_ex f "2" (Vector2.create 301.0 536.0) 11.0 1.0 Color.black;
          draw_text_ex f "2" (Vector2.create 299.0 534.0) 11.0 1.0 Color.white;
          draw_text_ex f "3" (Vector2.create 749.0 256.0) 11.0 1.0 Color.black;
          draw_text_ex f "3" (Vector2.create 747.0 254.0) 11.0 1.0 Color.white;
          draw_text_ex f "4" (Vector2.create 749.0 396.0) 11.0 1.0 Color.black;
          draw_text_ex f "4" (Vector2.create 747.0 394.0) 11.0 1.0 Color.white;
          draw_text_ex f "5" (Vector2.create 749.0 536.0) 11.0 1.0 Color.black;
          draw_text_ex f "5" (Vector2.create 747.0 534.0) 11.0 1.0 Color.white;

          (* Crop description helpers *)
          let draw_desc txt x y =
            draw_text_ex fo txt (Vector2.create x y) 25.0 1.0 Color.black;
            draw_text_ex fo txt (Vector2.create (x -. 0.5) y) 25.0 1.0 cream
          in
          let draw_prices crop x y =
            draw_text_ex fo
              (string_of_int (C.crop_database crop).buy_price)
              (Vector2.create x y) 30.0 1.0 cream;
            draw_text_ex fo
              (string_of_int (C.crop_database crop).sell_price)
              (Vector2.create (x +. 119.0) y)
              30.0 1.0 cream
          in

          (* Typewriter stuff *)
          let dt = get_frame_time () in
          typing_accumulator := !typing_accumulator +. dt;
          let chars_to_add =
            int_of_float (!typing_accumulator *. typing_speed)
          in
          if chars_to_add > 0 then begin
            message_index :=
              min
                (String.length !current_message)
                (!message_index + chars_to_add);
            typing_accumulator := 0.0
          end;
          let displayed_message =
            String.sub !current_message 0 !message_index
          in
          draw_text_ex fo displayed_message
            (Vector2.create 425.0 185.0)
            25.0 1.0 Color.black;

          (* CROP DESCRIPTIONS AND PRICES! *)
          draw_desc "Soft, golden wheat perfect" 365.0 343.0;
          draw_desc "for milling and fresh bread." 365.0 366.0;
          draw_prices C.Wheat 421.0 394.0;
          draw_desc "Sweet and delicately grown" 365.0 483.0;
          draw_desc "strawberries!" 365.0 506.0;
          draw_prices C.Strawberry 421.0 534.0;
          draw_desc "Vine-grown grapes, super" 813.0 203.0;
          draw_desc "fresh and juicy!" 813.0 226.0;
          draw_prices C.Grape 869.0 254.0;
          draw_desc "Sun-kissed tomatoes plump" 813.0 343.0;
          draw_desc "with summer flavor!" 813.0 366.0;
          draw_prices C.Tomato 869.0 394.0;
          draw_desc "Big, hearty pumpkins great" 813.0 483.0;
          draw_desc "for a pie or rich stew." 813.0 506.0;
          draw_prices C.Pumpkin 869.0 534.0
      | _ -> ())
  | _ -> ()
