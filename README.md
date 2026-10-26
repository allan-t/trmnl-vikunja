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

`src/settings.yml` holds the polling config and settings; `src/full.liquid` is the full layout.
Tests mock the Vikunja API with fixtures in `tests/fixtures/` and a fixed clock (`now:`).

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
