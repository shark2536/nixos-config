#!/usr/bin/env python3
"""Bangun emoji.json untuk emoji picker Quickshell dari data Unicode + CLDR (nama Inggris & Indonesia).

Pemakaian: gen-emoji.py <folder-unicode-emoji> <folder-cldr>   (JSON ditulis ke stdout)
Lokasi file dicari rekursif, jadi tata letak folder di paket Nix tidak perlu ditebak.
"""
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

# Urutan harus sama dengan tab di EmojiPicker.qml (0 = Recent, diisi runtime).
GROUPS = {
    "Smileys & Emotion": 1, "People & Body": 2, "Animals & Nature": 3,
    "Food & Drink": 4, "Travel & Places": 5, "Activities": 6,
    "Objects": 7, "Symbols": 8, "Flags": 9,
}
SKIN_TONES = range(0x1F3FB, 0x1F400)

# Bahasa sehari-hari yang tidak ada di CLDR.
EXTRA = {
    "👍": "mantap sip oke jempol", "👌": "oke sip mantap", "🔥": "mantap keren panas api",
    "💯": "mantap sempurna seratus", "😂": "ngakak wkwk lol", "🤣": "ngakak wkwk guling",
    "😭": "nangis sedih huhu", "🥺": "memelas mohon", "🙏": "makasih terima kasih tolong maaf",
    "😎": "keren santai", "❤️": "cinta sayang suka", "🫡": "siap hormat", "🗿": "moai diam",
    "😅": "waduh gugup", "🤔": "hmm mikir bingung", "😴": "ngantuk tidur", "🎉": "selamat pesta yeay",
    "💀": "mati ngakak wkwk", "🤝": "deal sepakat salaman", "👏": "tepuk tangan bagus",
}


def find_file(root, name, parent=None):
    for dirpath, _dirs, files in os.walk(root):
        if name in files and (parent is None or os.path.basename(dirpath) == parent):
            return os.path.join(dirpath, name)
    return None


def key_of(text):
    return text.replace("\ufe0f", "")


def read_annotations(cldr_root, lang):
    tts, words = {}, {}
    for folder in ("annotationsDerived", "annotations"):  # annotations menimpa derived
        path = find_file(cldr_root, lang + ".xml", folder)
        if not path:
            continue
        for el in ET.parse(path).getroot().iter("annotation"):
            cp, text = el.get("cp"), (el.text or "").strip()
            if not cp or not text:
                continue
            if el.get("type") == "tts":
                tts[key_of(cp)] = text
            else:
                words[key_of(cp)] = [w.strip() for w in text.split("|") if w.strip()]
    return tts, words


LINE = re.compile(r"^([0-9A-Fa-f ]+?)\s*;\s*(\S+)\s*#\s*(\S+)\s+E[\d.]+\s+(.+)$")


def read_emoji_test(path):
    group = None
    for raw in open(path, encoding="utf-8"):
        raw = raw.rstrip("\n")
        if raw.startswith("# group:"):
            group = raw.split(":", 1)[1].strip()
            continue
        m = LINE.match(raw)
        if not m or m.group(2) != "fully-qualified" or group not in GROUPS:
            continue
        codepoints = [int(c, 16) for c in m.group(1).split()]
        if any(c in SKIN_TONES for c in codepoints):  # versi warna kulit: belum didukung
            continue
        yield m.group(3), m.group(4), GROUPS[group]


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    unicode_root, cldr_root = sys.argv[1], sys.argv[2]
    test = find_file(unicode_root, "emoji-test.txt")
    if not test:
        sys.exit("emoji-test.txt tidak ditemukan di " + unicode_root)
    en_tts, en_words = read_annotations(cldr_root, "en")
    id_tts, id_words = read_annotations(cldr_root, "id")

    out = []
    for char, fallback_name, group in read_emoji_test(test):
        k = key_of(char)
        name = en_tts.get(k) or fallback_name
        terms = [name, *en_words.get(k, []), id_tts.get(k, ""), *id_words.get(k, []),
                 EXTRA.get(char, EXTRA.get(k, ""))]
        seen, words = set(), []
        for term in terms:
            term = term.lower().strip()
            if term and term not in seen:
                seen.add(term)
                words.append(term)
        out.append({"e": char, "n": name, "k": " ".join(words), "g": group})

    if len(out) < 1000:
        sys.exit("hanya %d emoji terbaca, data Unicode kemungkinan rusak" % len(out))
    json.dump(out, sys.stdout, ensure_ascii=False, separators=(",", ":"))


if __name__ == "__main__":
    main()
