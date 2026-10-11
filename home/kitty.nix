# Konfigurasi kitty (dipertahankan persis seperti sebelumnya).
{
  xdg.configFile."kitty/kitty.conf".text = ''
    shell .

    font_family JetBrainsMono Nerd Font Mono
    font_size 12.0
    bold_font auto
    italic_font auto
    bold_italic_font auto

    background_opacity 0.7
    confirm_os_window_close 0

    cursor_trail 1

    linux_display_server auto

    scrollback_lines 2000
    wheel_scroll_min_lines 1

    enable_audio_bell no

    window_padding_width 4

    globinclude colors.conf

    adjust_line_height 100%
    adjust_column_width 100%
  '';
}
