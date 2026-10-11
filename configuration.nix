{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ]; 
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
	boot.loader = {
		grub = {
			enable = true;
			device = "nodev";
			efiSupport = true;
			useOSProber = true;
		};
		efi.canTouchEfiVariables = true;
		efi.efiSysMountPoint = "/boot/efi";
	};
  boot.initrd.availableKernelModules = [ "hid_apple" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  hardware.graphics = {
  	enable = true;
	enable32Bit = true;
  };

  fonts.packages = with pkgs; [
 	jetbrains-mono
 	nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.defaultFonts = {
  	monospace = [ "JetBrains Mono" ];
	sansSerif = [ "JetBrains Mono" ];
	serif = [ "JetBrains Mono" ];
  };

  networking.hostName = "nixos"; # Define your hostname.

  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Jakarta";

  i18n.defaultLocale = "en_US.UTF-8";

  services.displayManager.sddm = {
  	enable = true;
	wayland.enable = true;
  };

  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users."shrky" = {
    isNormalUser = true;
    description = "shrky";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  programs.firefox.enable = true;
  programs.hyprland.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
  vim 
  wget
  fastfetch
  spotify
  git
  pciutils
  ];

  system.stateVersion = "26.05";
}
