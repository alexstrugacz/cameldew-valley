open Raylib

let pause_screen = ref None
let font = ref None

let load () =
  pause_screen := Some (load_texture "assets/display/pause-screen.png");
  font := Some (load_font "assets/fonts/PressStart2P-Regular.ttf")

let unload () =
  Option.iter unload_texture !pause_screen;
  Option.iter unload_font !font

let draw_pause () =
  match !pause_screen with
  | None -> ()
  | Some t -> (
      draw_rectangle 0 0 1280 720 (Color.create 0 0 0 120);
      draw_texture_ex t
        (Vector2.create (640.0 -. (354.0 *. 0.8)) 120.0)
        0.0 0.8 Color.white;
      match !font with
      | None -> ()
      | Some f ->
          let shadow_text txt x y size spacing color =
            draw_text_ex f txt
              (Vector2.create (x -. 5.0) (y -. 5.0))
              size spacing color
          in
          draw_text_ex f "GAME PAUSED"
            (Vector2.create 445.0 115.0)
            35.0 2.0 Color.black;
          shadow_text "GAME PAUSED" 445.0 115.0 35.0 2.0 Color.white;
          draw_text_ex f "Controls:"
            (Vector2.create 430.0 200.0)
            17.0 0.5 Color.black;
          shadow_text "Controls:" 433.0 203.0 17.0 0.5 Color.white;
          draw_text_ex f "WASD to move character"
            (Vector2.create 430.0 240.0)
            12.0 0.5 Color.white;
          shadow_text "WASD" 434.0 244.0 12.0 0.5 (Color.create 120 240 76 255);
          draw_text_ex f "F to interact with shop/crop/soil"
            (Vector2.create 430.0 280.0)
            12.0 0.5 Color.white;
          shadow_text "F" 434.0 284.0 12.0 0.5 (Color.create 240 160 100 255);
          draw_text_ex f "1/2/3/4/5 to select seed/buy crop"
            (Vector2.create 430.0 320.0)
            12.0 0.5 Color.white;
          shadow_text "1/2/3/4/5" 434.0 324.0 12.0 0.5
            (Color.create 100 140 220 255);
          draw_text_ex f "P to pause/unpause"
            (Vector2.create 430.0 360.0)
            12.0 0.5 Color.white;
          shadow_text "P" 434.0 364.0 12.0 0.5 (Color.create 250 100 160 255);
          draw_text_ex f "Earn as many coins as you"
            (Vector2.create 430.0 440.0)
            14.0 0.5 Color.white;
          draw_text_ex f "can before time runs out!"
            (Vector2.create 430.0 470.0)
            14.0 0.5 Color.white)
