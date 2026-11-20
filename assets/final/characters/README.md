# Approved human character assets

Approved static masters are immutable copies of the 2026-11-19 reviewed front/side pairs in `approved_static/` (left front, right side). The four `approved_actions/` sheets are 3 columns x 4 rows: frames0-5 walk,6-8 work,9 turn preparation,10 curious,11 caught. Original walk atlases are retained for history but are no longer the production renderer input.

Rendering: women190px, security200px; one fixed scale per action atlas, per-frame foot translation, no independent frame resizing. AN walk cycle spans96px of actual movement; staff60px. Player speed and gameplay timing are unchanged. Source side masters determine identity; no monster atlas or old human walk sheet was used as generation reference. New actions were made with built-in imagegen from each approved front/side pair, requesting identical anatomy/hair/outfit/palette/outline, moderate steps, fixed cells and baseline.

Static master SHA-256:
- an: f6acd3da65472bae350c21553e49a8e38d33a033d70e452f72bfb23882c78ba3
- manager: 8be6569397ad0f44770ee7b143d2edceaa5c4b512fd862cafe56c5cdc10403c4
- security: 36b93c4efc6f13f1676c2249191e9472b6037c1ff2147a6438fe742f9ab5625a
- cleaner: 85cd236e8aa41c92998b244e1b047c4673f498aa0e70d1104a60ed24a5840296

Prior user feedback accepted static art and found overall motion basically suitable. Pixel-perfect frame identity, contact and cross-platform visual quality are not claimed automatically verified. See docs/progress.md for exact validation scope.
