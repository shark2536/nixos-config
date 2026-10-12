{ config, pkgs, ... }:

{
  dconf.settings = {
    "it/miak/Smile" = {
      show-notifications = false;
    };
  };

  xdg.configFile."hypr/configs/user-overrides.lua".text = ''
    -- Personal overrides, dofile'd last oleh hyprland.lua

    -- Auto-start Smile service di background saat booting
    hl.config({
      exec_once = {
        "smile --gapplication-service",
      }
    })

    -- Launcher: CTRL + SUPER + SPACE (Instan via GTK IPC + Hyprland rule)
    hl.bind("CTRL + SUPER + SPACE", hl.dsp.exec_cmd("[float; move cursor -50% -50%] smile"))

    -- Monitor rules
    hl.monitor({ output = "DP-1", mode = "1920x1080@144", position = "0x0", scale = "1" })

    -- Window Opacity & Decoration Rules
    hl.config({
      decoration = {
        active_opacity = 0.99,
        inactive_opacity = 0.7,
      }
    })

    -- Mouse: matikan acceleration
    hl.config({
      input = {
        sensitivity = 0,
        accel_profile = "flat",
      }
    })

    -- Key repeat
    hl.config({
      input = {
        repeat_delay = 200,
        repeat_rate = 60,
      }
    })
  '';
}
