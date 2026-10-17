# Daftar emoji (nama Inggris + Indonesia) untuk emoji picker, dibangun dari data Unicode & CLDR.
{
  runCommand,
  python3,
  unicode-emoji,
  cldr-annotations,
}:

runCommand "mugen-emoji-data.json" { nativeBuildInputs = [ python3 ]; } ''
  python3 ${../scripts/gen-emoji.py} ${unicode-emoji} ${cldr-annotations} > $out
''
