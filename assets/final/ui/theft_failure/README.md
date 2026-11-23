# Theft caught presentation assets

The three CGs and `story_cn_en.json` were selectively copied from the user-provided `Theft_Failure_CG_Pack.zip`. The pack README identifies the CGs as AI-generated static narrative art based on the project's approved Q-style characters. The source archive and temporary extraction directory are not part of the project.

Runtime mapping is by the real `Staff.card_id` value (`SECURITY`, `CLEANER`, or `MANAGER`), not by floor, room, or the player's active card. The image is presentation only and does not award a card or alter task state.

The JSON keeps the supplied Chinese and English dialogue as source data. Runtime display passes each Chinese source string through the project's gettext catalog in `localization/en.po`.
