# 01: Walking skeleton: flat Project - Task list

**What to build:** A `trmnlp` Recipe that, on the full layout, shows my open Tasks across all Projects as a flat list of "Project - Task" rows. It polls Vikunja every 15 minutes with the base URL and API token supplied as Recipe settings (token sent as a Bearer header). Tasks are requested not-done, sorted by due date then Priority. Vikunja Tasks carry only a Project id, so a second polling request resolves Project names. Both test seams exist: rendering the template from a fixture response with a fixed "now", and a static check of the polling config.

**Blocked by:** None (can start immediately)

**Status:** resolved

- [x] Recipe previews locally with `trmnlp` and is importable into TRMNL
- [x] Base URL and API token are settings, not hardcoded; token is sent as a Bearer header
- [x] Polling requests only open Tasks, sorted by due date ascending then Priority descending, first page only, every 15 minutes
- [x] Project names are resolved from a second polling request
- [x] Full layout renders each Task as "Project - Task" in request order
- [x] Fixture-render test and static polling-config test both pass
