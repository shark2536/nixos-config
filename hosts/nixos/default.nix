# Konfigurasi khusus mesin ini (hostname "nixos").
{
  imports = [
    ./hardware-configuration.nix # dibuat otomatis oleh nixos-generate-config, jangan diedit
    ../../modules/nixos
  ];

  networking.hostName = "nixos";

  # Jangan diubah walau sudah upgrade NixOS; dipakai untuk kompatibilitas data lama.
  system.stateVersion = "26.05";
}
