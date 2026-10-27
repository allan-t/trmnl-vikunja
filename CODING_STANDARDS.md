# Coding standards

Read during review. Use the terms in `GLOSSARY.md` (Recipe, Task, Project, Priority) in code, tests and comments.

- **One source of truth.** Define each constant once. How many columns a Layout flows its Tasks through is the `columns` argument in its `src/<layout>.liquid`; how many rows fit is decided on screen by `fit_script` in `src/shared.liquid`.
- **One block per feature.** Each visual element is a partial in `src/shared.liquid`; each behaviour has its own spec file under `tests/`.
- **Specs assert visible text.** Render through the helpers in `tests/spec_helper.rb` and check what the screen shows, not template internals.
- **Matching style.** New Liquid and specs match the surrounding naming and structure.
- **No deploy from CI.** Workflows run tests and lint only; they never push to a live TRMNL Recipe.
