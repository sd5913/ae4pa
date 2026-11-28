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

The main scene plays these two MP3 files as looping background music:

```text
res://assets/music/propulsive_tension_2.mp3
res://assets/music/the_haunted_ballroom_1.mp3
```

WAV files are uncompressed alternatives. M4A files are preserved source copies;
Godot's built-in audio importers do not support this format. Do not reference
them as AudioStream resources.

New games start The Haunted Ballroom-1 with the prologue. Completing the 309
rescue switches to Propulsive Tension-2. Loaded memories resume the track that
matches their rescue progress. Returning to the main menu stops the music.

## Finale score

The user supplied The Final Word as an Opus track in an M4A container.
The Godot resource is `res://assets/music/the_final_word.mp3`.
It plays once from the finale chapter card through the ending dialogue, then stops
when the success screen appears.
