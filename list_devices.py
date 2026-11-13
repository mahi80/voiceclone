"""List audio devices and host APIs for picking devices in the Seed-VC GUI.

Run with the venv python (needs sounddevice):
    .\\.venv\\Scripts\\python.exe .\\list_devices.py
"""

import sys

try:
    import sounddevice as sd
except ImportError:
    print("sounddevice not installed. Use .venv\\Scripts\\python.exe or run setup.ps1.")
    sys.exit(1)

try:
    default_in, default_out = sd.default.device
except Exception:
    default_in, default_out = -1, -1

print("idx | dir | hostapi        | ch  | name")
print("-" * 72)
for i, d in enumerate(sd.query_devices()):
    dirs = []
    if d["max_input_channels"] > 0:
        dirs.append("IN ")
    if d["max_output_channels"] > 0:
        dirs.append("OUT")
    host = sd.query_hostapis(d["hostapi"])["name"]
    marker = ""
    if i == default_in:
        marker += " [default in]"
    if i == default_out:
        marker += " [default out]"
    print(f"{i:>3} | {'/'.join(dirs):^3} | {host:<14} | {d['max_input_channels']:>2}/{d['max_output_channels']:<2} | {d['name']}{marker}")

print()
print("For Teams voice conversion:")
print("  converter INPUT  = the speaker's headset mic (prefer the WASAPI entry)")
print("  converter OUTPUT = 'CABLE Input (VB-Audio Virtual Cable)'  <- playback side")
print("  Teams MIC        = 'CABLE Output (VB-Audio Virtual Cable)' <- recording side")
print("If the CABLE devices are missing, install VB-Audio Cable and reboot.")
