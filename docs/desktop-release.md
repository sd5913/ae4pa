# Linux and macOS desktop packages

The [Godot desktop packages workflow](../.github/workflows/godot-desktop-release.yml) uses the standard Godot 4.7.2 editor and matching official export templates. The existing Windows build continues to produce its own CI artifact.

## Review a build

Open the **Godot desktop packages** run associated with the pull request. The run summary links the preview artifacts. GitHub may require sign-in to download Actions artifacts. After the workflow reaches a successful conclusion, extract the artifact wrapper and then the ZIP inside it.

- **Linux x86-64** includes `MonsterHotel.x86_64` and `MonsterHotel.pck`. Keep them together and run `./MonsterHotel.x86_64` from the extracted directory. The runner extracts the same ZIP after Actions artifact transfer and launches it headlessly with fresh Chinese and saved English profiles.
- **macOS Universal 2 unsigned review** contains `Monster Hotel.app` and `UNSIGNED-REVIEW.txt`. Godot exports the Universal 2 app on Linux. A macOS runner downloads and extracts the ZIP, then checks the bundle metadata, executable mode, Intel and Apple silicon slices, and ad hoc signature. The review app has an ad hoc signature for local testing. It has no Developer ID signature or notarization. Use the notarized Release for regular Gatekeeper installation.

The workflows compare the three dialogue files with the source and check the main scene and English catalog in the exported PCKs. The existing Godot and Windows checks cover source-level localization changes. Headless startup and bundle inspection leave graphics, input, real-machine Gatekeeper launch, and gameplay for playtesting.

A manual run of **Godot desktop packages** also produces preview artifacts. GitHub exposes **Run workflow** once the workflow exists on the default branch. Choose the branch to review. Manual runs never request the signing environment or prepare a Release draft.

## Configure release signing

Before the first release, Giovanni or another authorized repository administrator sets up **Settings → Environments → macos-release**. Under deployment branches and tags, use **Selected branches and tags**, allow only a **Tag** rule for `v*`, and leave branch rules empty. Add a required reviewer who can verify the tagged commit and scope, and enable prevention of self-review. In repository rulesets, keep `main` protected and restrict creation, movement and deletion of `v*` tags to authorized release maintainers. The workflow checks that GitHub reports `main` as protected and that the tag points to a first-parent commit of that branch.

The Apple Developer account holder supplies the certificate and notarization credentials securely. Giovanni or an authorized repository administrator adds these six values as **environment secrets** in `macos-release`.

| Secret | Value |
| --- | --- |
| `MACOS_CERTIFICATE` | Base64 of a password-protected PKCS#12 (`.p12`) export of the **Developer ID Application** certificate and its private key. On macOS, use `base64 -i certificate.p12 \| tr -d '\r\n'` and paste the resulting text. |
| `MACOS_CERTIFICATE_PASSWORD` | The PKCS#12 export password, as plain text in the secret field. |
| `MACOS_SIGNING_IDENTITY` | The full certificate common name in the form `Developer ID Application: Organization Name (TEAMID)`, with no surrounding quotes. |
| `ASC_API_KEY_P8` | Base64 of the App Store Connect **team** API private key file (`.p8`). Use `base64 -i AuthKey_KEYID.p8 \| tr -d '\r\n'` and paste the resulting text. |
| `ASC_API_KEY_ID` | The App Store Connect key ID, as plain text. |
| `ASC_API_ISSUER_ID` | The team API key's Issuer ID (UUID) from App Store Connect, as plain text. |

Store the certificate, private keys and passwords outside the repository. The signing job checks that all six secrets exist, imports the certificate into a temporary keychain, signs with hardened runtime and a secure timestamp, and requires Apple's `Accepted` notarization status. It staples the app before creating the distributable ZIP. It then extracts the ZIP and verifies the signature, ticket and Gatekeeper assessment. If any of these stages fails, the workflow cannot prepare the Release draft.

## Prepare and publish a version

1. Students merge the reviewed PR through protected `main`. Before tagging, check the preview run, the existing runtime and Windows checks, and the signing environment setup.
2. An authorized student or maintainer pushes a fresh `vMAJOR.MINOR.PATCH` tag (for example, `v1.0.0`) on the selected commit from protected `main`. The reviewer verifies the tag and approves the `macos-release` job in Actions.
3. When both packages pass, the tag workflow creates a draft under [GitHub Releases](https://github.com/sd5913/ae4pa/releases), with `monster-hotel-linux-x86_64.zip` and `monster-hotel-macos-universal.zip` attached. Students review the assets and notes before publishing.
4. On a real Mac with default Gatekeeper settings, download the published ZIP in a browser, extract it in Finder and open `Monster Hotel.app` normally. Confirm launch and check graphics, audio and input. Record macOS version, chip, tag and outcome. Test on both Apple silicon and Intel where available.

If a draft upload is interrupted, inspect the existing draft and its assets before retrying. A maintainer can remove an incomplete draft and choose **Re-run failed jobs** on the original tag run. Keep the tag on the reviewed commit.

The workflow follows the [course build workflow](https://github.com/sd5913/godot-game-template/blob/main/.github/workflows/build.yml), [course packaging script](https://github.com/sd5913/godot-game-template/blob/main/.github/scripts/package-release.sh), [Tetrilaunch signing workflow](https://github.com/venetanji/tetrilaunch/blob/staging/.github/workflows/desktop.yml), and [Apple notarization workflow](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow).
