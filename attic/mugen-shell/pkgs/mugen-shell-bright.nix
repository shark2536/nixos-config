# Varian mugen-shell dengan patch tampilan milik kamu (teks putih, tanpa fade, font JetBrains Mono).
# Langkah 1-3 sama persis dengan yang dulu ada di flake.nix; langkah 4 = patch lock screen, langkah 5 = emoji picker.
{
  runCommand,
  mugen-shell,
  emoji-data,
}:

runCommand "mugen-shell-bright" { } ''
  cp -r ${mugen-shell}/shell $out
  chmod -R u+w $out

  # 1) ikon & teks bar = putih opaque
  sed -i 's/darkTextPrimary: Qt.rgba(0.92, 0.92, 0.96, 0.90)/darkTextPrimary: "#ffffff"/' $out/lib/Colors.qml
  sed -i 's/lightTextPrimary: Qt.rgba(0.92, 0.92, 0.96, 0.90)/lightTextPrimary: "#ffffff"/' $out/lib/Colors.qml

  # 2) fade idle -> penuh (wifi, bluetooth, notif, tray, volume, ime, dll)
  find $out -name '*.qml' -exec sed -i 's/? 1.0 : 0.6/? 1.0 : 1.0/g; s/? 1.0 : 0.75/? 1.0 : 1.0/g' {} +
  sed -i 's/normalOpacity: 0.6/normalOpacity: 1.0/' $out/components/common/IconButton.qml

  # 3) font global -> JetBrains Mono
  find $out -name '*.qml' -exec sed -i 's/M PLUS 1 Code/JetBrains Mono/g; s/M PLUS 2/JetBrains Mono/g' {} +

  # 4) lock screen: tombol power (shutdown/sleep/restart/logout) wajib password dulu.
  #    Gagal dengan jelas (fuzz=0) kalau file upstream berubah, bukan diam-diam rusak.
  patch -p1 --fuzz=0 -d $out -i ${../patches/lock-power-auth.patch}

  # 5) emoji picker: jendela baru yang keluar dari bar dan muncul di atas cursor.
  #    Patch kecil menyambungkannya ke Bar/ModeManager/shell.qml; file & data emoji ditambahkan utuh.
  patch -p1 --fuzz=0 -d $out -i ${../patches/emoji-picker-hooks.patch}
  cp ${../qml/EmojiPicker.qml} $out/windows/EmojiPicker.qml
  mkdir -p $out/data
  cp ${emoji-data} $out/data/emoji.json

  # assertion (pakai if/then biar aman dari set -e)
  if ! grep -q 'darkTextPrimary: "#ffffff"' $out/lib/Colors.qml; then
    echo "PATCH GAGAL: Colors.qml"
    exit 1
  fi
  if find $out -name '*.qml' -exec grep -l '? 1.0 : 0.6\|? 1.0 : 0.75' {} + | grep -q .; then
    echo "PATCH GAGAL: masih ada fade"
    exit 1
  fi
  if ! grep -q 'pendingPowerAction' $out/lock-shell.qml; then
    echo "PATCH GAGAL: lock screen power-auth"
    exit 1
  fi
  if ! grep -q 'emojiToggleRequested' $out/lib/ModeManager.qml; then
    echo "PATCH GAGAL: emoji picker"
    exit 1
  fi
''
