"""Subset the site's web fonts to the scripts the invitation actually needs.

This trims the bundled font payload while keeping enough coverage that guest
entered names and comments still render: basic + extended Latin everywhere, and
the full Arabic block where an Arabic font is used.

Variable fonts keep their variation axes (wght), so the `fontVariations` used by
`AppTypography` continue to work.

Dev-only tool. Requires fontTools:

    python -m pip install fonttools brotli

Usage (defaults operate in place on assets/fonts):

    python tool/subset_fonts.py
    python tool/subset_fonts.py --dest build/fonts-subset   # preview sizes
"""

import argparse
import os
import subprocess
import sys

LATIN = (
    "U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,"
    "U+0304,U+0308,U+0329,U+2000-206F,U+20AC,U+2122,U+2191,U+2193,"
    "U+2212,U+2215,U+FEFF,U+FFFD"
)
LATIN_EXT = (
    "U+0100-02BA,U+02BD-02C5,U+02C7-02CC,U+02CE-02D7,U+02DD-02FF,"
    "U+1D00-1DBF,U+1E00-1E9F,U+1EF2-1EFF,U+2020,U+20A0-20AB,U+20AD-20C0,"
    "U+2113,U+2C60-2C7F,U+A720-A7FF"
)
ARABIC = (
    "U+0600-06FF,U+0750-077F,U+0870-088E,U+0890-0891,U+0897-08E1,"
    "U+08E3-08FF,U+200C-200E,U+2010-2011,U+204F,U+2E41,U+FB50-FDFF,"
    "U+FE70-FEFF"
)

# Font file name -> Unicode ranges to keep.
FONTS = {
    "CormorantGaramond-Variable.ttf": f"{LATIN},{LATIN_EXT}",
    "GreatVibes-Regular.ttf": f"{LATIN},{LATIN_EXT}",
    "Jost-Variable.ttf": f"{LATIN},{LATIN_EXT}",
    "Amiri-Regular.ttf": f"{LATIN},{LATIN_EXT},{ARABIC}",
    "Amiri-Bold.ttf": f"{LATIN},{LATIN_EXT},{ARABIC}",
    "ArefRuqaa-Regular.ttf": f"{LATIN},{ARABIC}",
    "ArefRuqaa-Bold.ttf": f"{LATIN},{ARABIC}",
}


def subset(src: str, dst: str, ranges: str) -> None:
    tmp = dst + ".tmp" if os.path.abspath(src) == os.path.abspath(dst) else dst
    subprocess.run(
        [
            sys.executable,
            "-m",
            "fontTools.subset",
            src,
            f"--unicodes={ranges}",
            "--layout-features=*",
            "--name-IDs=*",
            f"--output-file={tmp}",
        ],
        check=True,
    )
    if tmp != dst:
        os.replace(tmp, dst)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", default=os.path.join("assets", "fonts"))
    parser.add_argument("--dest", default=os.path.join("assets", "fonts"))
    args = parser.parse_args()

    os.makedirs(args.dest, exist_ok=True)
    total_before = 0
    total_after = 0
    for name, ranges in FONTS.items():
        src = os.path.join(args.source, name)
        dst = os.path.join(args.dest, name)
        if not os.path.exists(src):
            print(f"skip (missing): {src}")
            continue
        before = os.path.getsize(src)
        subset(src, dst, ranges)
        after = os.path.getsize(dst)
        total_before += before
        total_after += after
        print(
            f"{name:34} {before // 1024:5} KB -> {after // 1024:5} KB "
            f"({100 * (before - after) // before}% smaller)"
        )
    print(
        f"{'TOTAL':34} {total_before // 1024:5} KB -> {total_after // 1024:5} KB"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
