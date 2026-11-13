"""Trim and normalize a reference recording for voice conversion.

Keeps the first N seconds of speech after leading silence, mono 44.1 kHz WAV.

    .\\.venv\\Scripts\\python.exe .\\prep_reference.py my_recording.m4a ref_me.wav --seconds 15
"""

import argparse
import shutil
import subprocess
import sys


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("input", help="source recording (any format ffmpeg reads)")
    ap.add_argument("output", help="output wav path")
    ap.add_argument("--seconds", type=float, default=15.0, help="max speech duration (default 15)")
    args = ap.parse_args()

    ffmpeg = shutil.which("ffmpeg")
    if not ffmpeg:
        print("ffmpeg not found. Install it: winget install Gyan.FFmpeg  (then reopen the shell)")
        sys.exit(1)

    af = (
        "silenceremove=start_periods=1:start_threshold=-50dB:start_silence=0.3,"
        f"atrim=0:{args.seconds},"
        "loudnorm=I=-18:TP=-1.5:LRA=11"
    )
    cmd = [ffmpeg, "-y", "-i", args.input, "-af", af, "-ac", "1", "-ar", "44100",
           "-sample_fmt", "s16", args.output]
    print(" ".join(cmd))
    if subprocess.run(cmd).returncode != 0:
        sys.exit("ffmpeg failed")

    probe = subprocess.run(
        [ffmpeg, "-i", args.output, "-f", "null", "-"],
        capture_output=True, text=True,
    )
    for line in probe.stderr.splitlines():
        if "Duration:" in line:
            print(f"Wrote {args.output} ({line.strip()})")
            break


if __name__ == "__main__":
    main()
