Type: task
Status: resolved

# Safe private-plugin deploy

Ensure the deploy path is safe for the repo's private plugin and that repo-side documentation clearly explains the source-of-truth rules.

## Answer

- Keep the repository as the source of truth for the private plugin. The checked-in config in `src/settings.yml` must be the canonical configuration, not the TRMNL dashboard.
- Warn about the sync-bot conflict: if a sync-bot is active, it can overwrite live metadata and conflict with the repo's values.
- Preserve the plugin id contract: the workflow must require `id: 520678` and fail before pushing if the value is missing or changed.
- After the first deploy, verify the live URL and API token are not reset or blanked. If either value has drifted, stop and restore the repo's expected config before the next deploy.
- Keep the guidance in repo documentation only; do not introduce a wizard or live-dashboard instruction flow.

This is captured in the repo docs and the static deployment workflow contract tests.
