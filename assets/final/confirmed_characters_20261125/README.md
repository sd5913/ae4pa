# Approved runtime dialogue portraits

Current user-approved selection: Carol keeps the team integration from the
running main@4d86f95 (`character_art_v2.gd`, including task/tutorial portraits).
Only Terese's four portraits and the manager neutral portrait are overridden by
this module. The prepared Carol PNGs below remain retained assets for future use.

The 10 textures come from `art_sources/confirmed_characters_20261125/portraits/`.
The original 27 approved PNGs remain unchanged in that archive, with SHA-256 checksums.
Runtime copies use a transparent 1280 × 1440 canvas, uniform scaling and horizontal
centering. Expressions are not independently alpha-trimmed at runtime. No art is redrawn.

| Image | Uniform scale | Top offset (pixels) |
| --- | --- | --- |
| Carol smile; Terese neutral; manager neutral | 1 | 0 |
| Carol thinking, suspicious, surprised | 0.98 | 4 |
| Carol determined | 1440 / 1330 | 0 |
| Terese happy, teasing | 1408 / 1463 | 1440 − source height × scale |
| Terese playful | 1.2 | 1440 − source height × scale |

The supplied playful portrait has a shorter crop; scaling and padding place its
lower edge on the shared baseline without reconstructing the missing artwork.
The existing dialogue scene controls display size and position.

`scenes/ui/confirmed_character_portraits.gd` selects personal Terese/manager images.
Carol's existing team expression aliases are unchanged. Terese's 16 cafe
lines use neutral (4), happy (4), teasing (6), playful (2). Every manager expression
uses neutral. Scene chibi sprites, movement and CGs are unchanged.
