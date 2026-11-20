# English UI fit review · 2026-11-19

Skill: gstack design-review, adapted to native Godot. Scope: English text fit in the existing brass hotel interface. No redesign, commit, push, external review send, browser detector or generated mockup. `codex_reviews` is disabled; this is a primary review. The dirty tree was preserved under the user's repository instructions.

## First impression and hierarchy

The rain cover and brass/green art communicate the same hotel setting in both languages. My eye goes to the title, start action and hotel entrance. Once playing, the development heading and repeated objective competed with the illustrated HUD. In the202 dialogue, the last line shared space with Continue, making the instruction harder to finish reading.

## Findings and verified changes

| Finding | Impact | Change | Evidence |
|---|---|---|---|
| 001: English202 paragraph overlaps Continue | High | Dialogue height grows upward from measured wrapped-text height, keeping a16px footer gap; layout refreshes on line, locale and size changes | [before](screenshots/before/dialogue202.png), [after](screenshots/after/dialogue202.png) |
| 002: HUD captions exceed fixed slot height and long Cleaner name crowds identity plaque | Medium | Reserve116px slot height; use consistent shorter English Cleaner ID; preserve active word, color and frame | [before](screenshots/before/hud202.png), [after](screenshots/after/hud202.png) |
| 003: Inventory's long card name reaches ornamental edge; equipped text approaches action row | Medium | Shorter translated name,15px collection labels and14px equipped labels; no change to selection/equip behavior | [before](screenshots/before/bag.png), [after](screenshots/after/bag.png) |
| 004: Development heading/controls/repeated objective/restart crowd game view | Medium | Hide those scene children in normal play; retain the gameplay notice and compact English route feedback. Nodes and test/API hooks remain | [before](screenshots/before/hud202.png), [after](screenshots/after/hud202.png) |

All four are verified by native before/after images. The menu, guide, phone, offer, pause and failure pages were also reviewed; their existing style and controls were retained. Typography and spacing in this focused sample improve from C to B; this is a subjective scoped assessment, not a full product score. AI-pattern/detector scoring was not run and is not claimed.

## Quick wins applied

- Reserve action-row space from actual text height rather than reducing every dialogue font.
- Keep a consistent compact ID name across cards, instructions and HUD.
- Keep only necessary in-game feedback above the corridor.

## Regression and constraints

The new layout check first failed on the original text/button gap and HUD slot containment, then passed after the fix. Existing tests were not weakened or changed this round. Final16 invocations cover layout, prologue, UI components, bilingual persistence and201/202/core/floor interactions; see[results](results.json).

The first rerun read an English preference left by preview while several existing tests assert Chinese. Those failures are retained under first_rerun; final tests use a new profile that defaults to Chinese. Temporary runners also reused the previous bilingual evidence directory before their output paths were corrected: the old master command outcomes/source hashes remain, but some old raw logs were overwritten. This is explicitly documented in the historical log_provenance.md; no original logs were fabricated.

Only1280x720 on this Mac was visually checked. Windows, exports and other device sizes remain outside this review. The native states use explicit fixtures and do not add human acceptance results.
