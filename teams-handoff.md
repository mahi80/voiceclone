# Voice stand-in — laptop setup (10 min)

Everything below runs on the laptop that joins the Teams call. The final result:
whatever you say into your headset comes out of Teams in the target voice.

## 0. Check the hardware first

Open PowerShell and run:

```powershell
nvidia-smi
```

You must see an NVIDIA GPU (RTX 3060 or better). If this fails, stop and tell the
organizer — the converter cannot run without CUDA.

## 1. Install (once)

1. Python 3.10: `winget install --id Python.Python.3.10 -e` (tick "Add to PATH" if using the installer).
2. VB-Audio Cable from https://vb-audio.com/Cable/ — install, reboot.
3. Unzip the `voiceclone` folder, then in PowerShell:

```powershell
cd <path>\voiceclone
powershell -ExecutionPolicy Bypass -File .\setup.ps1
powershell -ExecutionPolicy Bypass -File .\check_cuda.ps1
```

`check_cuda.ps1` must print PASS. First `setup.ps1` run downloads ~3 GB.

## 2. Before the call

1. Plug in the headset (required — speakers cause echo into the converter).
2. Start the converter: `powershell -ExecutionPolicy Bypass -File .\run_realtime.ps1`
3. In its window:
   - HostAPI: `WASAPI` (fallback `MME` if the stream won't open)
   - Input: your headset microphone
   - Output: `CABLE Input (VB-Audio Virtual Cable)`
   - Reference audio: `ref_you.wav` (provided)
   - Diffusion steps `4-6`, Block time `0.25-0.30`, Crossfade `0.04`,
     Extra context left `2.5`, right `0.02`, Max prompt `3-10`, CFG `0.7`
   - Press **Start** and keep the window open.
4. Teams → Settings → Devices:
   - Microphone: **CABLE Output (VB-Audio Virtual Cable)**
   - Noise suppression: **Off**
   - Speakers: your headset (NOT CABLE)
5. Run Teams → Settings → "Make a test call" and listen to the playback.

## 3. During the call

- Keep the converter window open and not minimized/covered by other GPU apps.
- Laptop on charger, power plan High Performance.
- Headset mic close to the mouth, quiet room — clean input = clean output.
- Expect ~0.5 s delay. Speak a touch slower and don't talk over people.
- If the voice sounds robotic: raise Diffusion steps; if it drifts from the target
  person: stop, tell the organizer (needs a better reference clip).

## 4. If something breaks

| Symptom | Fix |
|---|---|
| Converter: stream open error | Switch HostAPI to MME for both devices; WASAPI exclusive OFF |
| No audio in Teams | Teams mic must be CABLE **Output**, converter output CABLE **Input** |
| CABLE devices missing | Reinstall VB-Cable, reboot |
| check_cuda fails | NVIDIA driver update; confirm laptop has RTX GPU |
| CPU pegged / stutter | Close browser tabs/games; plugged-in power plan |
