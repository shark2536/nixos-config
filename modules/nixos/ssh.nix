{ pkgs, ... }:

{
  # Mengaktifkan OpenSSH service
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Menambahkan SSH program & support agent
  programs.ssh = {
    startAgent = true;
  };

  # Pastikan git & openssh terinstall di environment system
  environment.systemPackages = with pkgs; [
    git
    openssh
  ];
}
