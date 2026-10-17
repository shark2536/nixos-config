# MacShell + MacLock di-copy ke ~/.config/quickshell saat home-manager activate.
# Sengaja COPY (bukan symlink/xdg.configFile): README MacShell melarang mengakses
# folder install lewat symlink (Quickshell >= 0.3 menurunkan folder state dari path
# yang dipakai untuk menjangkaunya).
#
# Update MacShell = bump input flake lalu rebuild; `macshell-update` sengaja
# tidak dipasang karena hasilnya akan ditimpa activation berikutnya.
{ inputs, lib, pkgs, ... }:

{
  home.activation.installMacShell =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      PATH=${lib.makeBinPath [ pkgs.rsync ]}:$PATH
      dest="$HOME/.config/quickshell"
      mkdir -p "$dest"

      # --delete: folder ini murni kode dari repo; pengaturan user disimpan
      # terpisah di ~/.config/macbar, ~/.config/macdock, ~/.config/macwidgets.
      rsync -a --delete ${inputs.macshell}/MacShell/ "$dest/MacShell/"
      rsync -a --delete ${inputs.macshell}/MacLock/  "$dest/MacLock/"
    '';
}
