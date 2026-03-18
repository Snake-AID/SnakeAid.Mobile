# Sound Assets

Place audio files here for the SnakeAid app alerts.

## Required files

### `snake_alert.mp3`
- Used for: Snake catching request assigned notification modal
- Recommended: Short, urgent alarm loop (~2-3 seconds, will loop automatically)
- Volume: High/loud sounds recommended (volume is set to max in code)
- Format: MP3 or OGG Vorbis

## Notes
- Files referenced via `AssetSource('sounds/<filename>.mp3')` from `audioplayers` package
- The code silently falls back to vibration-only if the file is missing
