# Font. Semua default memakai JetBrains Mono (sesuai tampilan dotfiles kamu).
{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    inter # font default MacShell
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    # Cadangan untuk karakter yang tidak ada di JetBrains Mono (emoji & huruf Jepang/Mandarin/Korea).
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrains Mono" ];
    sansSerif = [ "JetBrains Mono" ];
    serif = [ "JetBrains Mono" ];
    emoji = [ "Noto Color Emoji" ];
  };
}
