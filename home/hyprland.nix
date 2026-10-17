# hyprland.lua kini dikelola Home Manager.
# Isinya = gabungan user-overrides lama (monitor, opacity, input) + kebutuhan MacShell
# (autostart, layer rules, keybind). Kalau hyprland.lua lamamu punya pengaturan
# lain, port ke sini — file lama di-backup otomatis (backupFileExtension = "backup").
{ ... }:

{
  xdg.configFile."hypr/hyprland.lua".text = ''
    -- ============================================================
    -- MacShell (0-ss/MacShell) — bar + dock gaya macOS (Quickshell)
    -- ============================================================

    -- Monitor rules (dari user-overrides lama)
    hl.monitor({ output = "DP-1", mode = "1920x1080@144", position = "0x0", scale = "1" })

    -- Window opacity (dari user-overrides lama). Blur WAJIB aktif untuk efek glass.
    hl.config({
      decoration = {
        active_opacity = 0.99,
        inactive_opacity = 0.9,
        blur = { enabled = true },
      },
    })

    -- Mouse & keyboard (dari user-overrides lama)
    hl.config({
      input = {
        sensitivity = 0,
        accel_profile = "flat",
        repeat_delay = 200,
        repeat_rate = 60,
      },
    })

    -- MacLock: izinkan lock screen yang crash di-restart (take over lock)
    hl.config({
      misc = {
        allow_session_lock_restore = true,
      },
    })

    -- Autostart MacShell. Loop while ini juga jadi mitigasi crash Quickshell
    -- (lihat "Known issues" di README MacShell): shell mati -> jalan lagi 1 dtk.
    hl.on("hyprland.start", function()
        hl.exec_cmd("sh -c 'while :; do qs -c MacShell; sleep 1; done'")
    end)

    -- Layer rules: blur untuk permukaan glass
    hl.layer_rule({ name = "macdock",  match = { namespace = "macdock"  }, blur = true, ignore_alpha = 0.2,  no_anim = true })
    hl.layer_rule({ name = "macspot",  match = { namespace = "macspot"  }, blur = true, ignore_alpha = 0.05, no_anim = true })
    hl.layer_rule({ name = "macbarbg", match = { namespace = "macbarbg" }, blur = true, ignore_alpha = 0.05, no_anim = true })
    hl.layer_rule({ name = "macshot",  match = { namespace = "macshot"  }, no_anim = true })

    -- Keybinds MacShell
    local qs = "qs -c MacShell ipc call "

    hl.bind("SUPER + V",          hl.dsp.exec_cmd(qs .. "spotlight clipboard"))
    hl.bind("SUPER + period",     hl.dsp.exec_cmd(qs .. "spotlight emoji"))
    hl.bind("SUPER + Space",      hl.dsp.exec_cmd(qs .. "spotlight toggle"))
    hl.bind("ALT + TAB",          hl.dsp.exec_cmd(qs .. "switcher next"))
    hl.bind("CTRL + ALT + W",     hl.dsp.exec_cmd(qs .. "wallpapers toggle"))
    hl.bind("PRINT",              hl.dsp.exec_cmd(qs .. "screenshot region"))

    -- MacLock (lock screen)
    hl.bind("SUPER + L",          hl.dsp.exec_cmd("sh ~/.config/quickshell/MacLock/lock-via-ipc.sh"))
  '';
}
