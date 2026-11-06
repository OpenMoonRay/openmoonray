#!/usr/bin/env python3

# Copyright 2026 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

"""
Render wrapper for the profiling suite.

Runs the renderer and simultaneously streams its combined stdout/stderr to the
terminal (so CTest can display it) and to a dated log file.  Output
files are placed in a per-test subdirectory with names like:

    2026-06-03_1_sca_scene.txt   (log)
    2026-06-03_1_sca_scene.exr   (rendered image)

Multiple runs accumulate in the same directory, enabling performance tracking
over time.

Usage:
    profile_render.py --output-dir <dir> --mode <abbrev> [--version-tag <ver>]
                      <renderer> [renderer-args ...]

Inherits the RATS_MOONRAY_THREADS behaviour from render.py: when the
environment variable is set to a positive integer, '-threads N' is injected
into the moonray command line.
"""

import argparse
import os
import shutil
import subprocess
import sys
from datetime import datetime


def main():
    parser = argparse.ArgumentParser(
        description='Profiling render wrapper: runs the renderer and saves dated output.'
    )
    parser.add_argument(
        '--output-dir',
        required=True,
        metavar='DIR',
        help='Per-test output directory. Images and logs are written here.'
    )
    parser.add_argument(
        '--scene-name',
        required=True,
        metavar='NAME',
        help='Scene stem name included in the output filename (e.g. veach-mis).'
    )
    parser.add_argument(
        '--mode',
        required=True,
        metavar='MODE',
        help='Exec-mode abbreviation embedded in the filename (e.g. sca, vec, xpu, hd).'
    )
    parser.add_argument(
        '--version-tag',
        default='',
        metavar='VER',
        help='Version string embedded in the filename (e.g. 1). Omitted when empty.'
    )
    parser.add_argument(
        '--result-image',
        default='',
        metavar='PATH',
        help='When set, also copy the rendered image to this fixed path after a '
             'successful render. Used by the diff test stage.'
    )
    parser.add_argument(
        'renderer',
        help='Renderer executable (moonray, hd_render, etc.)'
    )
    parser.add_argument(
        'args',
        nargs=argparse.REMAINDER,
        help='Arguments forwarded verbatim to the renderer.'
    )

    parsed = parser.parse_args()

    # Build the base name: YYYY-MM-DD[_version]_mode_scenename.
    date_str = datetime.now().strftime('%Y-%m-%d')
    if parsed.version_tag:
        base_name = f"{date_str}_{parsed.version_tag}_{parsed.mode}_{parsed.scene_name}"
    else:
        base_name = f"{date_str}_{parsed.mode}_{parsed.scene_name}"

    os.makedirs(parsed.output_dir, exist_ok=True)
    log_path = os.path.join(parsed.output_dir, base_name + '.txt')
    img_path = os.path.join(parsed.output_dir, base_name + '.exr')

    cmd = [parsed.renderer]

    # Inject -threads for moonray when RATS_MOONRAY_THREADS is set.
    if parsed.renderer == 'moonray':
        moonray_threads = os.getenv('RATS_MOONRAY_THREADS', '')
        if moonray_threads:
            try:
                num_threads = int(moonray_threads)
                if num_threads > 0:
                    cmd.extend(['-threads', str(num_threads)])
                    print(f'[ProfileTest] Using {num_threads} threads for moonray', flush=True)
            except ValueError:
                print(
                    f'[ProfileTest WARNING] RATS_MOONRAY_THREADS={moonray_threads!r} '
                    'is not a valid integer, ignoring.',
                    file=sys.stderr
                )

    cmd.extend(parsed.args)
    # profile_render.py owns -out so the filename can be determined at run time.
    cmd.extend(['-out', img_path])

    with open(log_path, 'w') as log:
        log.write(f"Command: {' '.join(cmd)}\n\n")
        log.flush()

        try:
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
            )

            for line in process.stdout:
                sys.stdout.write(line)
                sys.stdout.flush()
                log.write(line)
                log.flush()

            process.wait()
            returncode = process.returncode

            if returncode == 0 and parsed.result_image:
                os.makedirs(
                    os.path.dirname(os.path.abspath(parsed.result_image)),
                    exist_ok=True
                )
                shutil.copy2(img_path, parsed.result_image)
                msg = (
                    f'[ProfileRender] Result image: {parsed.result_image}\n'
                )
                sys.stdout.write(msg)
                log.write(msg)

            return returncode

        except Exception as e:
            msg = f'Error executing renderer: {e}\n'
            sys.stderr.write(msg)
            log.write(msg)
            return 1


if __name__ == '__main__':
    sys.exit(main())
