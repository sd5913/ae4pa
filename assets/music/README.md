# Music Assets

Two tracks supplied by venetanji on 2026-11-26. All six supplied files are
preserved without transcoding; filenames use the project's lowercase convention.

| Track | Filename stem | Duration | Supplied formats |
| --- | --- | --- | --- |
| Propulsive Tension-2 | `propulsive_tension_2` | 67.88 seconds | MP3, WAV, M4A |
| The Haunted Ballroom-1 | `the_haunted_ballroom_1` | 123.64 seconds | MP3, WAV, M4A |

All versions contain stereo audio at 48 kHz. The WAV files use 16-bit PCM; the
M4A files contain Opus audio. Embedded metadata identifies Suno as the creation
tool and venetanji as the artist on the MP3 files. Original metadata is retained;
no additional license terms were supplied.

## Godot Integration

Use the MP3 files for compressed playback, for example:

```text
res://assets/music/propulsive_tension_2.mp3
res://assets/music/the_haunted_ballroom_1.mp3
```

WAV files are uncompressed alternatives. M4A files are preserved source copies;
Godot's built-in audio importers do not support this format. Do not reference
them as AudioStream resources.

This delivery adds assets only. Scene assignment, volume, looping, transitions,
and listening checks remain for the playback integration stage.
