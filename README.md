# VoiceClone — real-time voice conversion for Teams

Turns the speaker's microphone into a target voice (your voice) live, and feeds it
to Microsoft Teams through a virtual audio cable.

**Chosen path: RVC v2, trained on 15 min of the target voice, run by VCClient.**

```
his headset mic -> VCClient (Mahi.pth) -> CABLE Input -> Teams mic = CABLE Output
```

- Model: RVC v2, 40 kHz, F0-guided, 300 epochs (235 slices, 15 min dataset).
- Weights live in `models/Mahi/` (not committed — binaries): `Mahi.pth` + index.
- Inference on the friend's laptop needs **no NVIDIA GPU** — VCClient's DirectML
  build runs on any DX12 GPU (Intel iGPU included), fallback CPU mode.
- Setup instructions for the person in the call: [teams-handoff.md](teams-handoff.md).

This beats the original zero-shot route because a trained model holds timbre far
better at conversation length and runs without CUDA. The Seed-VC zero-shot kit
below is kept only as a fallback for NVIDIA machines.

Reported latency: ~0.2–0.4 s conversion + ~0.1–0.2 s cable/Teams buffering.
Budget roughly 0.5 s turnaround — sounds "dubbed", not natural.

---

## Fallback: Seed-VC zero-shot (needs NVIDIA CUDA)

Engine: [Seed-VC](https://github.com/Plachtaa/seed-vc) real-time mode (zero-shot:
no training, uses a 10-30 s reference clip).

```
his headset mic -> seed-vc realtime -> CABLE Input -> Teams mic = CABLE Output
```

## Requirements

- Windows 10/11 x64
- **NVIDIA GPU with CUDA** (RTX 3060 8 GB or better). Seed-VC's realtime path uses
  `torch.cuda.Event` unconditionally, so it will not run on CPU or Intel/AMD GPUs.
- Python **3.10** (seed-vc pins torch 2.4.0, which has no wheels for newer Pythons)
- Headset (speaker output leaks into the mic and destroys the conversion)
- ~10 GB disk for venv + models (models download on first run)
- [VB-Audio Cable](https://vb-audio.com/Cable/) (free) — virtual microphone driver
- Optional: `git` and `ffmpeg` on PATH (setup script clones seed-vc; prep script trims clips)

## Install (on the laptop that will run the converter)

1. Install Python 3.10 — `winget install --id Python.Python.3.10 -e` or from python.org,
   tick "Add python.exe to PATH".
2. Install VB-Audio Cable, reboot.
3. From this folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

4. Verify the GPU:

```powershell
.\check_cuda.ps1
```

Must print the NVIDIA device and PASS. If it fails, stop — fix CUDA/driver first.

## Reference clip (you, once)

Record 10-30 s of clean conversational speech (quiet room, headset mic, no music).
Normalize it:

```powershell
.\.venv\Scripts\python.exe .\prep_reference.py .\my_recording.m4a .\ref_you.wav
```

The engine only uses the first `Max prompt length` seconds (3-10 s) as the voice
prompt, so a clean 10-15 s clip is plenty.

## Run

```powershell
powershell -ExecutionPolicy Bypass -File .\run_realtime.ps1
```

In the GUI:

| Setting | Value |
|---|---|
| HostAPI | `WASAPI` (if the stream fails to open, use `MME` for both devices) |
| Input device | the speaker's headset microphone |
| Output device | `CABLE Input (VB-Audio Virtual Cable)` |
| Reference audio | `ref_you.wav` |
| Diffusion steps | 4-6 (higher = better quality, more delay) |
| Block time | 0.25-0.30 s |
| Crossfade | 0.04 s |
| Extra context (left) | 2.0-2.5 s |
| Extra context (right) | 0.02 s |
| Max prompt length | 3-10 s |
| Inference CFG rate | 0.7 |
| WASAPI exclusive | off (VB-Cable rejects exclusive mode) |

Press Start. The first run downloads the Seed-VC checkpoints from Hugging Face.

## Teams wiring (all on the speaker's laptop)

1. Teams → Settings → Devices → **Microphone = `CABLE Output (VB-Audio Virtual Cable)`**.
2. Noise suppression = **Off** (Teams' suppressor mangles converted audio).
3. Auto mic sensitivity/gain = **Off** if the option exists.
4. Speakers/headset = the physical headset, **not** CABLE.
5. Run Teams' built-in test call and listen to the converted playback.

## Offline quality check (no Teams involved)

Converts a file once, so you can judge identity/artifacts before a live call:

```powershell
cd seed-vc
..\.venv\Scripts\python.exe inference.py --source .\examples\source\source_s1.wav `
  --target ..\ref_you.wav --output ..\out --diffusion-steps 30
```

Use `--semi-tone-shift` only if the target voice's register differs from the speaker's.

## Tuning

| Symptom | Knob |
|---|---|
| Too much delay | Lower block time, extra context left, diffusion steps |
| Robotic / metallic | Raise diffusion steps, raise extra context left |
| Clicks at chunk seams | Keep crossfade >= 0.04 s |
| Identity drifts | Longer cleaner reference, raise max prompt length |
| Dropouts | Close other GPU apps, power plan High, charger plugged in |

## If this isn't close enough to you

- **Fine-tune** the Seed-VC model on your voice (minutes on a rented T4) — better identity.
- **RVC v2 per-speaker model + VCClient** — most stable, lowest latency, needs a
  30-60 min training run; supports client -> remote GPU server if the laptop is weak.
- **One-off call** — a paid desktop app (e.g. Voice.ai) does a decent clone in minutes.

## Consent

Only use a voice you have the speaker's consent to clone. Teams recordings and
transcripts will attribute the converted speech to your account, so everyone on
the call must be told it's a stand-in.
