# Hardware: Intel i3-10105F + AMD RX 6700 XT + keyboard Apple.
{
  # Firmware & microcode (microcode Intel ikut aktif lewat opsi ini).
  hardware.enableRedistributableFirmware = true;

  # GPU AMD: modul amdgpu dimuat sedini mungkin supaya layar langsung benar.
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # untuk aplikasi/game 32-bit (Steam, Wine, dll)
  };

  # Keyboard Apple: tombol F1-F12 jadi fungsi biasa (fnmode=2).
  boot.initrd.availableKernelModules = [ "hid_apple" ];
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  # Root btrfs: kompresi + kurangi tulis metadata akses (hemat SSD & ruang).
  fileSystems."/".options = [
    "compress=zstd"
    "noatime"
  ];
}
