#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Pandoc filter to process code blocks with class "wavedrom" into
wavedrom-generated images.

Needs `wavedrompy` from pip and inkscape for svg2png conversion.
"""

import os
import sys
import subprocess

from pandocfilters import toJSONFilter, Para, Image, get_filename4code, get_caption, get_extension


def wavedrom(key, value, format, _):
    if key == 'CodeBlock':
        [[ident, classes, keyvals], code] = value

        if "wavedrom" in classes:
            caption, typef, keyvals = get_caption(keyvals)

            filename = get_filename4code("wavedrom", code)
            filetype = get_extension(format, "png", html5="svg", html="svg", latex="eps")

            src = filename + '.json'
            svg = filename + '.svg'
            dest = filename + '.' + filetype


            if not os.path.isfile(dest):
                txt = code

                with open(src, mode="w") as f:
                    f.write(txt)

                subprocess.run(["wavedrompy", "--input", src, "--svg", svg],stdout=subprocess.DEVNULL)
                subprocess.run(["inkscape", "-z", "-e", dest, svg],stdout=subprocess.DEVNULL)
                sys.stderr.write('Created image ' + dest + '\n')

            return Para([Image([ident, [], keyvals], caption, [dest, typef])])

if __name__ == "__main__":
    toJSONFilter(wavedrom)
