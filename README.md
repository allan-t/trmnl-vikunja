# trmnl-vikunja
A recipe for TRMNL for the task tracking app Vikunja

## Local preview and testing

Requires Docker; the `trmnl/trmnlp` image provides everything else. Run from the repo root:

```sh
# Preview at http://localhost:4567 (copy .env.example to .env and set your Vikunja URL and token)
docker compose up

# Run the RSpec tests in tests/ (fixture render + polling config)
docker run --rm -v "$PWD:/plugin" trmnl/trmnlp test

# Lint the Recipe
docker run --rm -v "$PWD:/plugin" trmnl/trmnlp lint
```

`src/settings.yml` holds the polling config and settings; `src/full.liquid` is the full layout.
Tests mock the Vikunja API with fixtures in `tests/fixtures/` and a fixed clock (`now:`).
