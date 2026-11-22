# D: caught-theft failure UI evidence (2026-11-22)

This is a standalone Godot UI smoke scene, not a manual playthrough through the production theft interaction.

## Captures

- Chinese, 1280×720: `screenshots/zh_security.png`, `screenshots/zh_cleaner.png`, `screenshots/zh_manager.png`
- English, 960×540: `en960/en_security.png`, `en960/en_cleaner.png`, `en960/en_manager.png`
- Automated Movie Maker recording of the Chinese smoke scene: `theft_failure_smoke.avi` (135 frames at 30 FPS; about 4.5 seconds).

The capture scene invokes the D presentation API with each real staff role ID and checks that the corresponding project CG and bilingual four-beat script display. It does not fabricate a stolen card or mutate task state. The recording is a UI smoke demonstration, not footage of the live theft gameplay route.

## Tested

Godot `4.7.2.stable.official.ed1daf0bf` on Windows. Import, the Chinese and English theft-failure smoke scene, localization smoke, the existing UI regression scene, and `git diff --check` completed with exit code 0. The English capture ran with a 960×540 window override; Chinese screenshots used the 1280×720 project window. Godot logged a Windows root-certificate-store read error; it did not prevent these checks from completing.

The smoke checks cover all three role mappings, CG texture load, initial hold phase, four ordered localized lines, one-action-per-beat behavior, key echo suppression, the final separate action, return to the existing failure menu, and a single completion signal.

Captured stdout logs are under `logs/` (`import.log`, `theft-zh.log`, `theft-en.log`, `localization.log`, `ui-regression.log`).

## Not verified here

- A human triggering actual caught-theft failures for each staff role in the production main scene.
- Failure settlement count through the complete gameplay route, retry/checkpoint restoration, or return-to-menu flow. GameManager exposes `can_retry_current_task()` and `retry_current_task()`, but the main scene does not currently connect this Failure screen's request signals; A-side routing must wire those existing APIs before these buttons are end-to-end verified.
- Physical keyboard/touch input or exported builds.
