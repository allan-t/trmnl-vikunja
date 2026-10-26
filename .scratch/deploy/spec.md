# Deployment spec

## Safe private-plugin deploy

- The repository is the source of truth for the private TRMNL plugin. Keep the repo's `src/settings.yml` and checked-in workflow as the canonical configuration.
- Do not treat the live TRMNL dashboard as the canonical repo; if it diverges, fix the repo and redeploy.
- Warn about the sync-bot conflict: do not run or rely on a sync-bot while a manual deploy or first deploy is in progress.
- The plugin id is a contract. `src/settings.yml` must keep the expected `id: 520678`, and deployment should fail if it is missing or altered.
- After the first deploy, verify the live URL and token are not reset; the repo must remain the source of truth and any drift must be corrected before additional deploys.
- This is repo-side documentation only; do not add a wizard or deployment step that asks the operator to edit live values by hand.
