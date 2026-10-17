# Sisi user dari dotfiles mugen-shell (sisi sistem ada di modules/nixos/mugen-shell.nix).
{ inputs, mugen-shell-bright, ... }:

{
  imports = [ inputs.mugen-shell.homeManagerModules.default ];

  programs.mugen-shell = {
    enable = true;
    includeSystemDeps = false; # dependensi sudah dipasang di level sistem
    quickshellExecutable = "/run/current-system/sw/bin/quickshell";
    ai.enable = true;
    package = mugen-shell-bright;
  };
}
