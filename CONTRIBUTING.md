# Contributing to trmnl-vikunja

How to run, test, preview and release this Recipe. Just want to use it on your TRMNL? Read the [README](README.md) or the [user guide](docs/USER_GUIDE.md).

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

## Releasing

```sh
bin/pack   # builds _build/trmnl-vikunja.zip, the file TRMNL imports (needs only Docker)
```

Pushing a version tag (for example `git tag v1.0.0 && git push origin v1.0.0`) runs `.github/workflows/release.yml`: tests and lint first, then `bin/pack`, then the zip is attached to a GitHub Release. This publishes a file; it never pushes to a live TRMNL Recipe. The zip leaves out the plugin `id` from `settings.yml`, so importing it creates a new Recipe.

## Submitting to the Recipes directory

Publish from your own plugin in the TRMNL dashboard (its settings page has a publish action), not from the release zip; see TRMNL's [Plugin recipes](https://help.trmnl.com/en/articles/10122094-plugin-recipes) help article. Review runs CHEF first, then a person. The zip from `bin/pack` is for installing from GitHub: it leaves out the plugin `id` from `settings.yml`, and `tests/pack_spec.rb` checks that. Before submitting, run through [TRMNL's checklist](https://trmnl.com/blog/plugin-recipe-publishing-tips).

## Adding a test

Render the template with a fixed clock and mocked Vikunja responses, then assert on the visible text. One spec file per behaviour; Liquid partials live in `src/shared.liquid`:

```ruby
it 'shows the Project and Task' do
  expect(render_tasks([build_task(title: 'Buy milk')])).to have_text('Buy milk')
end
```

The helpers live in `tests/spec_helper.rb`. CI (`.github/workflows/test.yml`) runs the tests on every pull request. It also runs `trmnlp lint`.

## References

- [Vikunja API v2 docs](https://try.vikunja.io/api/v2/docs)
- [TRMNL developer docs](https://docs.usetrmnl.com/go/)
- [TRMNL custom plugin form builder](https://help.trmnl.com/en/articles/10513740-custom-plugin-form-builder): every `custom_fields` key in `src/settings.yml`, including `group` and `conditional_validation` (hides or shows fields by another field's value). The page is long and gets truncated when fetched, so read past the first page before concluding a key does not exist.
