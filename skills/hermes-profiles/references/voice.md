# Voice mode, STT, and TTS

Docs:
- https://hermes-agent.nousresearch.com/docs/user-guide/features/voice-mode
- https://hermes-agent.nousresearch.com/docs/user-guide/features/tts
- https://hermes-agent.nousresearch.com/docs/guides/use-voice-mode-with-hermes
- Wake word (hands-free start): https://hermes-agent.nousresearch.com/docs/user-guide/features/wake-word

Voice is **per profile**. Config keys live in that profile's `config.yaml`; API
keys in that profile's `.env`. Personality / SOUL wording is separate
(`soul-templates.md`). Skin / display chrome is separate (`display.md`).

Anytype maps the stack onto **Harness profile** (`stt_*` / `tts_*`) and
enablement / modes onto **Agent** (`voice_*`). Prefer those properties over
markdown-only Suggested runtime bullets. Apply into Hermes with this file;
Anytype does not push configs.

## What voice covers

| Surface | What it does |
|---------|----------------|
| CLI / TUI / Desktop mic loop | Push-to-talk (default `Ctrl+B`), silence VAD, optional spoken replies |
| Messaging voice replies | Telegram / Discord: speak replies (`/voice on` / `/voice tts`) |
| Discord voice channel | Bot joins VC, listens, replies in audio + text |
| `text_to_speech` tool | Agent can speak on demand when TTS is configured |
| Inbound voice notes | Auto-transcribe when `stt.enabled` (default true) |

Get **text Hermes working first**, then enable voice.

## Quick map

| Concern | Keys / CLI |
|---------|------------|
| Mic loop / barge-in / beeps | `voice.*` |
| Speech-to-text | `stt.*` |
| Text-to-speech | `tts.*` |
| Session toggle | `/voice`, `/voice on\|off`, `/voice tts`, `/voice status` |
| Discord VC | `/voice join`, `/voice leave` |
| Provider picker | `hermes tools` (TTS / STT sections) |
| Extras | PM `voice`, `messaging`, `tts-premium` (see guide) |

## Recommended default (zero / low cost)

```yaml
voice:
  record_key: "ctrl+b"
  submit_mode: "direct"       # TUI: direct | draft
  max_recording_seconds: 120
  auto_tts: false
  beep_enabled: true
  beep_volume: 0.3
  silence_threshold: 200
  silence_duration: 3.0
  voice_chat_mode: chained    # chained | gpt-live (Desktop)
  client_direct: true         # Desktop remote: call STT/TTS from client when possible
  barge_in: true
  stop_phrases: ["stop"]

stt:
  enabled: true
  echo_transcripts: true
  provider: "local"           # privacy + free default
  language: "en"              # "" = auto-detect
  streaming: false
  local:
    model: "base"             # tiny | base | small | medium | large-v3 | turbo

tts:
  provider: "edge"            # free default
  speed: 1.0
  edge:
    voice: "en-US-AriaNeural"
  streaming:
    min_len: 20               # ~6 for CJK
```

```bash
hermes -p <slug> config set stt.provider local
hermes -p <slug> config set stt.local.model base
hermes -p <slug> config set tts.provider edge
hermes -p <slug> config set tts.edge.voice en-US-AriaNeural
hermes -p <slug> config set voice.auto_tts false
hermes -p <slug> config set voice.voice_chat_mode chained
```

Quality presets (guide):

| Goal | STT | TTS |
|------|-----|-----|
| Zero cost | local (`base`) | edge |
| Speed / convenience | local `base` or groq | edge |
| Best quality | local `large-v3` or groq `whisper-large-v3` | elevenlabs |

## `voice.*` (CLI / Desktop loop)

| Key | Meaning |
|-----|---------|
| `record_key` | Push-to-talk (default `ctrl+b`) |
| `submit_mode` | TUI: `direct` submits transcript; `draft` leaves it in composer |
| `max_recording_seconds` | Hard cap |
| `auto_tts` | Speak replies when `/voice on` |
| `beep_enabled` / `beep_volume` | Record start/stop beeps |
| `silence_threshold` / `silence_duration` | VAD end-of-utterance |
| `stop_phrases` | Bare utterance ends voice chat (`["stop"]`; `[]` disables) |
| `voice_chat_mode` | Desktop: `chained` (STT→turn→TTS) or `gpt-live` (full-duplex OpenAI live voice that delegates to Hermes) |
| `gpt_live.voice` / `gpt_live.instructions` | Only when `gpt-live` |
| `client_direct` | Desktop remote: providers called from client when possible (`false` forces gateway relay) |
| `barge_in` / grace / threshold | Interrupt spoken reply while listening |

```bash
hermes -p <slug> config set voice.auto_tts true
hermes -p <slug> config set voice.submit_mode draft
hermes -p <slug> config set voice.silence_duration 4.0
hermes -p <slug> config set voice.voice_chat_mode chained
# In session: /voice on | /voice tts | /voice status | /voice off
```

## `stt.*` (speech-to-text)

Built-in providers (plugins add more): `local` | `groq` | `openai` | `mistral` |
`xai` | `elevenlabs` | `deepinfra` | …

| Key | Meaning |
|-----|---------|
| `enabled` | Auto-transcribe inbound voice notes (default true) |
| `echo_transcripts` | Post `🎙️ "…"` back to chat |
| `provider` | Active STT provider |
| `language` | Global hint; per-provider `language` wins; `""` = auto |
| `streaming` | Live partial text while speaking (`openai` / `xai` / `elevenlabs` / streaming plugins) |
| `local.model` | faster-whisper size |
| `prompt` / `local.initial_prompt` | Vocabulary bias (keep secrets out) |

Language resolution for every provider:
`stt.<provider>.language` → `stt.language` → `HERMES_LOCAL_STT_LANGUAGE` → auto.

```bash
hermes -p <slug> config set stt.provider groq
hermes -p <slug> config set stt.groq.model whisper-large-v3-turbo
hermes -p <slug> config set stt.language en
hermes -p <slug> config set stt.streaming false
```

Common keys (`.env`, never echo values): `GROQ_API_KEY`,
`VOICE_TOOLS_OPENAI_KEY` / `OPENAI_API_KEY`, `MISTRAL_API_KEY`, `XAI_API_KEY`,
`ELEVENLABS_API_KEY`, …

Local Whisper needs **no** API key. Model downloads on first use (~150 MB for
`base`). System deps for CLI mic: PortAudio, ffmpeg (Opus for Discord VC).

## `tts.*` (text-to-speech)

Built-in providers: `edge` (default) | `elevenlabs` | `openai` | `minimax` |
`mistral` | `gemini` | `xai` | `deepinfra` | `neutts` | `kittentts` | `piper` |
`nous` (Tool Gateway / portal-managed OpenAI TTS).

| Key | Meaning |
|-----|---------|
| `provider` | Active TTS provider |
| `speed` | Global speed; provider-specific `speed` overrides |
| `edge.voice` | e.g. `en-US-AriaNeural` |
| `elevenlabs.voice_id` / `model_id` | Premium voice |
| `openai.model` / `voice` | e.g. `gpt-4o-mini-tts` / `alloy` |
| `gemini.voice` / `persona_prompt_file` / `audio_tags` | Gemini voices + optional direction |
| `xai.voice_id` / `language` / `auto_speech_tags` | Grok TTS |
| `streaming.min_len` | Shortest first sentence (chars) for streaming speak |

Speed hierarchy: provider `speed` → `tts.speed` → `1.0`.

```bash
hermes -p <slug> config set tts.provider edge
hermes -p <slug> config set tts.edge.voice en-US-AriaNeural
hermes -p <slug> config set tts.speed 1.0
# Premium example (needs ELEVENLABS_API_KEY + tts-premium extra):
# hermes -p <slug> config set tts.provider elevenlabs
# hermes -p <slug> config set tts.elevenlabs.voice_id pNInz6obpgDQGcFmaJgB
```

Telegram voice bubbles need Opus. OpenAI / ElevenLabs / Mistral can emit Opus
natively; Edge / MiniMax / Gemini / xAI / local WAV providers need **ffmpeg**.

Nous Portal subscribers can use OpenAI TTS via the Tool Gateway without a
separate OpenAI key (`hermes setup --portal` or `hermes tools` → Nous
Subscription for TTS).

## Messaging modes

Inside Telegram / Discord (gateway running):

| Command / mode | Meaning |
|----------------|---------|
| `/voice off` | Text only |
| `/voice on` | Speak when the user sent voice (`voice_only`) |
| `/voice tts` | Speak every reply (`all`) |
| `/voice join` / `leave` | Discord voice channel (needs Connect / Speak + intents) |

Document intended messaging mode on the Agent page
(`messaging_voice_mode`: `off` | `voice_only` | `all`). Apply at runtime with
`/voice` or gateway session state; do not invent allowlist IDs in Anytype.

## Prerequisites (short)

```bash
# CLI mic + local STT (PM / source checkout)
cd ~/.hermes/hermes-agent && python -c "import pm; pm.sync_venv(['voice'], explicit=True)"
# Messaging bots
python -c "import pm; pm.sync_venv(['messaging'], explicit=True)"
# ElevenLabs
python -c "import pm; pm.sync_venv(['tts-premium'], explicit=True)"

# macOS system deps
brew install portaudio ffmpeg opus
```

NeuTTS's declared extra needs Python &lt; 3.14; Hermes runtime is 3.14, so prefer
Edge / other providers unless you run NeuTTS in a separate command environment.

## Clone / multi-profile notes

- `--clone` copies `config.yaml` voice / stt / tts blocks. Give clones their own
  keys in `.env` when using paid providers.
- One writer per profile. Two gateways on the same home corrupt state.
- Desktop Settings → Voice shows an **Applies to** chip when multiple profiles
  exist; default follows the active profile.

## Quick checklist

```bash
hermes -p <slug> config get stt.provider
hermes -p <slug> config get stt.local.model
hermes -p <slug> config get tts.provider
hermes -p <slug> config get tts.edge.voice
hermes -p <slug> config get voice.auto_tts
hermes -p <slug> config get voice.voice_chat_mode
# Session: /voice status
# After STT/TTS provider changes, restart CLI / gateway / Desktop as needed
```

## Safety

1. Do not paste STT/TTS API keys or allowlist IDs into chat.
2. Keep secrets out of `stt.prompt` / vocabulary hints sent to cloud STT.
3. Confirm before enabling Discord VC join on shared servers.
4. `gpt-live` uses OpenAI live voice and still delegates tool work to Hermes;
   treat it as a paid / credentialed path.
5. Editing Anytype voice fields does not change live `~/.hermes` until you apply
   with this skill (and the user has said the redesign pass is done).
