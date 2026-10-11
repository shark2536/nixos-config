# Sisi sistem dari dotfiles mugen-shell (sisi user ada di home/mugen-shell.nix).
{ inputs, ... }:

{
  imports = [ inputs.mugen-shell.nixosModules.default ];

  programs.mugen-shell.enable = true;
}
