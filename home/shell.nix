# Bash + alias. Alias ini juga berlaku di terminal kitty.
{ config, ... }:

let
  cfg = "${config.home.homeDirectory}/nixos-config";
  # `git add -A` dulu karena flake hanya "melihat" file yang sudah di-track git.
  stage = "git -C ${cfg} add -A";
in
{
  programs.bash = {
    enable = true;
    historyControl = [
      "ignoredups"
      "erasedups"
    ];
    historySize = 10000;

    shellAliases = {
      # --- NixOS ---
      nrs = "${stage} && nh os switch"; # terapkan config sekarang juga
      nrt = "${stage} && nh os test"; # coba dulu, tidak permanen (hilang saat reboot)
      nrb = "${stage} && nh os boot"; # terapkan saat reboot berikutnya
      nup = "nix flake update --flake ${cfg}"; # update semua input (nixpkgs dll)
      nupr = "nup && nrs"; # update lalu langsung rebuild
      ngc = "nh clean all --keep-since 7d --keep 3"; # bersihkan generasi & store lama
      ngens = "nixos-rebuild list-generations"; # daftar generasi sistem
      nfmt = "nix fmt ${cfg}"; # rapikan semua file .nix
      ncfg = "cd ${cfg}"; # pindah ke folder config
      ns = "nix search nixpkgs"; # cari paket

      # --- navigasi & file ---
      ".." = "cd ..";
      "..." = "cd ../..";
      ls = "eza --icons=auto --group-directories-first";
      ll = "eza -lh --icons=auto --group-directories-first";
      la = "eza -lah --icons=auto --group-directories-first";
      lt = "eza --tree --level=2 --icons=auto";
      grep = "grep --color=auto";
      df = "df -h";
      free = "free -h";
      mkdir = "mkdir -p";
      cls = "clear";

      # --- git ---
      gs = "git status -sb";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph --decorate -15";
      gd = "git diff";
    };
  };

  # Ctrl+R = cari history interaktif, `z nama-folder` = lompat ke folder yang sering dipakai.
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
}
