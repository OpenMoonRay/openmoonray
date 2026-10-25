#!/usr/bin/env python3

# Copyright 2026 DreamWorks Animation LLC
# SPDX-License-Identifier: Apache-2.0

"""
Render a profiling scene once and save the result as the canonical image.

Called by the CTest 'update' stage registered in ProfileTest.cmake:

    update_profile_canonical.py --exec-mode <mode> --test-rel-path <path>
                                 --image-name <stem.exr>
                                 <renderer> [renderer-args ...]

The canonical image is written to:
    $PROFILE_CANONICAL_DIR/<test-rel-path>/<exec-mode>/<image-name>

PROFILE_CANONICAL_DIR must be set in the environment before running.
Inherits the RATS_MOONRAY_THREADS behaviour: when set to a positive integer,
'-threads N' is injected into the moonray command line.
"""

import argparse
import os
import shutil
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(
        description='Generate a canonical image for a profiling scene.'
    )
    parser.add_argument(
        '--exec-mode',
        required=True,
        metavar='MODE',
        help='Execution mode used as the canonical subdirectory name '
             '(e.g. scalar, vector, xpu, default).'
    )
    parser.add_argument(
        '--test-rel-path',
        required=True,
        metavar='PATH',
        help='Scene parent path relative to PROFILE_SCENES_DIR '
             '(e.g. bitterli/bedroom).'
    )
    parser.add_argument(
        '--image-name',
        required=True,
        metavar='FILE',
        help='Output image filename (e.g. scene.exr).'
    )
    parser.add_argument(
        'renderer_cmd',
        nargs=argparse.REMAINDER,
        help='Renderer executable and all its arguments. '
             '-out <canonical> is appended automatically.'
    )

    parsed = parser.parse_args()

    canonical_dir_root = os.getenv('PROFILE_CANONICAL_DIR')
    if not canonical_dir_root:
        print('[ProfileUpdate] ERROR: PROFILE_CANONICAL_DIR is not set.',
              file=sys.stderr)
        print('[ProfileUpdate] Set this environment variable to the directory',
              file=sys.stderr)
        print('[ProfileUpdate] where canonical images should be stored.',
              file=sys.stderr)
        sys.exit(1)

    canonical_dir = os.path.join(
        canonical_dir_root, parsed.test_rel_path, parsed.exec_mode
    )
    os.makedirs(canonical_dir, exist_ok=True)
    canonical_path = os.path.join(canonical_dir, parsed.image_name)

    # Render to a temp path first so a partial render never corrupts the canonical.
    temp_path = canonical_path + '.updating'

    renderer_args = parsed.renderer_cmd
    if not renderer_args:
        print('[ProfileUpdate] ERROR: no renderer command was provided.',
              file=sys.stderr)
        sys.exit(1)

    renderer = renderer_args[0]
    cmd = list(renderer_args)

    # Inject -threads for moonray when RATS_MOONRAY_THREADS is set.
    if renderer == 'moonray':
        threads = os.getenv('RATS_MOONRAY_THREADS', '')
        if threads:
            try:
                n = int(threads)
                if n > 0:
                    cmd = [renderer, '-threads', str(n)] + cmd[1:]
                    print(f'[ProfileUpdate] Using {n} moonray threads.',
                          flush=True)
            except ValueError:
                print(
                    f'[ProfileUpdate] WARNING: RATS_MOONRAY_THREADS={threads!r} '
                    'is not a valid integer, ignoring.',
                    file=sys.stderr
                )

    cmd.extend(['-out', temp_path])

    print(
        f'[ProfileUpdate] Rendering canonical: '
        f'{parsed.test_rel_path}/{parsed.exec_mode}/{parsed.image_name}',
        flush=True
    )
    print(f'[ProfileUpdate] Command: {" ".join(cmd)}', flush=True)

    result = subprocess.run(cmd)

    if result.returncode != 0:
        if os.path.exists(temp_path):
            os.unlink(temp_path)
        print(
            f'[ProfileUpdate] Render failed (exit {result.returncode}).',
            file=sys.stderr
        )
        sys.exit(result.returncode)

    if not os.path.exists(temp_path):
        print(
            f'[ProfileUpdate] ERROR: renderer did not produce {temp_path}.',
            file=sys.stderr
        )
        sys.exit(1)

    shutil.move(temp_path, canonical_path)
    print(f'[ProfileUpdate] Canonical saved: {canonical_path}', flush=True)


main()
