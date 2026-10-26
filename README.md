# trmnl-vikunja
A recipe for TRMNL for the task tracking app Vikunja

## Local preview and testing

Requires Docker; the `trmnl/trmnlp` image provides everything else. Run from the repo root:

```sh
# Preview at http://localhost:4567 (copy .env.example to .env and set VIKUNJA_API_TOKEN; the base URL defaults to https://app.vikunja.cloud)
docker compose up

# Run the RSpec tests in tests/ (fixture render + polling config)
docker compose run --rm test

# Lint the Recipe
docker run --rm -v "$PWD:/plugin" trmnl/trmnlp lint
```

`src/settings.yml` holds the polling config and settings. `src/full.liquid`, `half_horizontal.liquid`, `half_vertical.liquid` and `quadrant.liquid` are the four layouts; they all render the shared `task_screen` partial in `src/shared.liquid`.
Tests mock the Vikunja API with fixtures in `tests/fixtures/` and a fixed clock (`now:`).

## Layout screenshots

```sh
bin/screenshots
```

Renders every layout, grouped and ungrouped, into `docs/screenshots/<layout>-<grouped|ungrouped>.png` from fixture data (`tests/fixtures/screenshot_*.json`) and a fixed clock. It needs only Docker: no Vikunja token, and `.trmnlp.yml` is not touched. Output is deterministic (checked: two runs, and a fresh run against the committed images, are byte-identical), so a diff in the images is a real change. Commit them with layout changes. CI reruns `bin/screenshots` and fails if `git status --porcelain docs/screenshots` shows anything (changed, new or deleted images).

Never commit a `.trmnlp.yml` with resolved values: `docker compose up` rewrites it, so keep the `{{ env.* }}` placeholders.

## Deployment safety for the private plugin

This repo is the source of truth for the private TRMNL plugin. Keep the live recipe in sync from this repo, not by editing the TRMNL dashboard and treating it as the canonical copy. This is repo-side documentation, not a wizard: the repository files are what must be reviewed and pushed.

- private plugin: the deploy path is for the repo's private plugin, not a public or shared recipe. Deploys should happen only from the checked-in repo state and only after the repo is clean and reviewed.
- source of truth: `src/settings.yml` is the canonical configuration for the plugin id, name, description, and custom fields. If the live plugin differs from the repo, fix the repo first and then redeploy.
- sync-bot conflict: do not run the sync-bot while a manual deploy is in flight. The sync-bot may rewrite the same plugin metadata or settings and conflict with the repo's values, especially the live URL and API token.
- plugin id contract: the plugin id is a contract with the live deployment. `src/settings.yml` must keep `id: 520678`, and the deploy job fails before pushing if that value is missing or changed.
- first deploy verification: after the first deploy, confirm the live URL and token are not reset. If the live URL or API token has been blanked, reset, or replaced, stop; restore the repo's expected settings and verify the live values before any additional deploys.

The deploy workflow is intentionally conservative: it tests and lints first, then enforces the plugin id guard before the `trmnlp push` call to avoid accidentally publishing the wrong plugin configuration.

## Adding a test

Render the template with a fixed clock and mocked Vikunja responses, then assert on the visible text. One spec file per behaviour; Liquid partials live in `src/shared.liquid`:

```ruby
it 'shows the Project and Task' do
  expect(render_tasks([build_task(title: 'Buy milk')])).to have_text('Buy milk')
end
```

The helpers live in `tests/spec_helper.rb`. CI (`.github/workflows/test.yml`) runs the tests on every pull request. It also runs `trmnlp lint`.

## References

- [Vikunja API docs (swagger)](https://try.vikunja.io/api/v1/docs)
- [TRMNL developer docs](https://docs.usetrmnl.com/go/)
