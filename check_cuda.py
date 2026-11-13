import sys

try:
    import torch
except ImportError:
    print("FAIL: torch not installed. Run setup.ps1.")
    sys.exit(1)

print(f"torch {torch.__version__}")
if not torch.cuda.is_available():
    print("FAIL: CUDA not available. Seed-VC real-time requires an NVIDIA GPU.")
    print("Check: NVIDIA driver installed, laptop has an RTX GPU, torch build is cu124.")
    sys.exit(1)

dev = torch.cuda.get_device_name(0)
vram = torch.cuda.get_device_properties(0).total_memory / (1024 ** 3)
print(f"GPU: {dev}")
print(f"VRAM: {vram:.1f} GB")

if vram < 7.5:
    print("WARN: under ~8 GB VRAM; real-time may OOM at default settings.")
print("PASS")
