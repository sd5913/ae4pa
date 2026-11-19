# Historical evidence note

`results.json` retains the original 13 passing invocations and their source SHA-256 values. During the later English UI review, the temporary runners reused this directory and overwrote some per-test `.log` files. Those rerun logs are preserved under `../a_english_ui_20261119/first_rerun/`; files with the same names here must not be treated as original-run raw logs. The historical command outcomes and hashes were recovered from the unchanged master index, not reconstructed from reruns. The later UI review has its own final evidence directory and source hashes.
