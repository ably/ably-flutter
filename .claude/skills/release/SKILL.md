---
description: "Create a release branch, bump version, update CHANGELOG, and regenerate lock files. Usage: /release patch|minor|major"
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
---

Read the current version from `pubspec.yaml` (the `version` property).

The bump type is: $ARGUMENTS

Compute the new version by incrementing the appropriate component of the current version:
- `patch` — increment the third number, keep major and minor (e.g. 1.2.43 → 1.2.44)
- `minor` — increment the second number, reset patch to 0 (e.g. 1.2.43 → 1.3.0)
- `major` — increment the first number, reset minor and patch to 0 (e.g. 1.2.43 → 2.0.0)

Then perform these steps in order:

1. Run `git checkout -b release/NEW_VERSION`

2. Update the version in these files:
   - `pubspec.yaml` — the `version` property
   - `README.md` — the `ably_flutter: ^OLD_VERSION` line in the Installation section (update to `^NEW_VERSION`)

3. Regenerate lock files:

   a. Run `flutter pub get` in `example/` and `test_integration/` to update their `pubspec.lock` files:
      ```
      cd example && flutter pub get && cd ..
      cd test_integration && flutter pub get && cd ..
      ```
      If either directory doesn't exist, skip it and note it in the summary.

   b. Regenerate iOS Podfile.lock files by running:
      ```
      pod install --project-directory=example/ios
      pod install --project-directory=test_integration/ios
      ```
      If CocoaPods is not installed or either directory doesn't exist, skip that directory and note it in the summary.

4. Commit all changed files together with message: `chore: bump version to NEW_VERSION`
   Stage: `pubspec.yaml`, `README.md`, `example/pubspec.lock`, `example/ios/Podfile.lock`, `test_integration/pubspec.lock`, `test_integration/ios/Podfile.lock` (only include files that actually changed).

5. Fetch merged PRs since the last release tag:
   ```
   gh pr list --state merged --base main --json number,title,mergedAt --limit 200
   ```
   Then get the date of the last release tag with:
   ```
   git log vOLD_VERSION --format="%aI" -1
   ```
   Filter the PRs to only those merged after that tag date. Format each as:
   ```
   - Short, one sentence summary from PR title [#NUMBER](https://github.com/ably/ably-flutter/pull/NUMBER)
   ```
   If the tag doesn't exist or there are no merged PRs, use a single `-` placeholder bullet instead.

6. In `CHANGELOG.md`, insert the following block immediately after the `# Changelog` heading (and its trailing blank line), before the first existing `## [` version entry:

```
## [NEW_VERSION](https://github.com/ably/ably-flutter/tree/vNEW_VERSION)

[Full Changelog](https://github.com/ably/ably-flutter/compare/vOLD_VERSION...vNEW_VERSION)

BULLETS_FROM_STEP_5

```

7. Commit `CHANGELOG.md` with message: `docs: update CHANGELOG for NEW_VERSION`

After completing all steps, show the user a summary of what was done. If PRs were found, list them. If the placeholder `-` was used instead, remind the user to fill in the bullet points in `CHANGELOG.md` before merging. Also remind them of the remaining manual steps: push the branch, open a PR, get approval, merge, tag `vNEW_VERSION`, and publish via the GitHub Release Workflow.