# Voice stand-in — laptop setup (RVC model, no GPU required)

Goal: you join the Teams call from your laptop, speak into your headset, and the
call hears the trained voice instead of yours. Two extra pieces make this work:

1. **VCClient** — real-time voice converter (runs the `Mahi.pth` model).
2. **VB-Audio Cable** — a fake "microphone" that carries converted audio into Teams.

No CUDA / NVIDIA GPU needed. A modern Intel or AMD laptop is fine.

## 0. What you need from me

| File | Size | What it is |
|---|---|---|
| `Mahi.pth` | 53 MB | trained voice model |
| `added_IVF1105_Flat_nprobe_1_Mahi_v2.index` | 130 MB | retrieval index (keeps the timbre sharp) |

Put both in one folder, e.g. `C:\voice\Mahi\`.

## 1. Install (once, ~15 min)

1. **VCClient (DirectML build)** —
   https://huggingface.co/wok000/vcclient000/resolve/main/vcclient_win_dml_2.1.4-alpha.zip
   Unzip to `C:\voice\vcclient\`. Windows may warn about an unsigned app: "More info" → "Run anyway".
2. **VB-Audio Cable** — https://vb-audio.com/Cable/ → `VBCABLE_Setup_x64.exe` → reboot.
   After reboot two devices appear: `CABLE Input` (playback) and `CABLE Output` (recording).
3. Plug in the headset. Speakers will echo into the converter.

## 2. Load the voice in VCClient

1. Double-click `start.bat` in the VCClient folder. A browser page opens
   (usually http://localhost:6006 or :7865 — the console window shows the port).
2. Model type: **RVC**. Upload / select `Mahi.pth`.
   - If it asks to convert to ONNX, accept and wait (1–3 min, one time only).
3. Index: point to `added_IVF1105_Flat_nprobe_1_Mahi_v2.index`. **Index rate 0.5–0.75.**
4. Audio:
   - Input: your **headset microphone**
   - Output: **`CABLE Input (VB-Audio Virtual Cable)`**
   - Chunk / block size ≈ **200 ms** start; pitch **0**
5. Press **Start**. Speak — the level meter should move and the OUTPUT LED should blink.

## 3. Point Teams at the converted audio

Teams → Settings (gear) → Devices:

- Microphone: **`CABLE Output (VB-Audio Virtual Cable)`**
- Noise suppression: **Off** (Teams' filters cut the voice model's detail)
- Speakers: your headset (**not** CABLE)

Then Teams → Devices → **Make a test call** and listen to yourself.

## 4. During the call

- Laptop on charger; close heavy apps.
- Headset mic 2–3 cm from the mouth, quiet room.
- Expect ~0.3–0.6 s delay on a DirectML laptop. Speak a little slower, don't interrupt.
- If it sounds robotic → raise chunk size to 250–300 ms.
- If the timbre drifts → index rate up to 0.75–1.0, chunk back to 200 ms.

## 5. If something breaks

| Symptom | Fix |
|---|---|
| `CABLE` devices missing | Reinstall VB-Cable, reboot, check Sound settings |
| Teams hears nothing | Mic must be CABLE **Output**; VCClient output must be CABLE **Input** |
| VCClient starts but no output | Output device still the headset — switch it to CABLE Input |
| Very laggy / stutter | Chunk size 300 ms, close background apps, try CPU mode |
| Voice sounds muffled | Noise suppression Off in Teams; index rate up |
| VCClient won't open | Antivirus blocked `start.bat`; allow it, or run the .exe directly |

## 6. Rough latency check

| Stage | Typical |
|---|---|
| VCClient conversion (DirectML iGPU) | 0.2–0.4 s |
| VB-Cable + Teams buffering | 0.1–0.2 s |
| **Total** | **0.3–0.6 s** |
