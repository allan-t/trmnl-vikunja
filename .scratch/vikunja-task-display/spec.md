Status: ready-for-agent

## Problem Statement

I track my work in Vikunja, but I have to open a browser or app to see what is due. I want my TRMNL e-ink device to show my open Tasks at a glance, with no interaction.

## Solution

A TRMNL Recipe that polls the Vikunja API every 15 minutes and renders my open Tasks on the full layout. Each row shows the Project name and Task name, the due date underneath, and a Priority icon. If more Tasks exist than fit, a footer says how many more. Empty and error states show a short message. The Vikunja base URL and API token are Recipe settings.

## User Stories

1. As a Vikunja user, I want my open Tasks shown on my TRMNL, so that I can see what to do without opening an app
2. As a Vikunja user, I want Tasks from all my Projects in one list, so that I get a complete picture
3. As a Vikunja user, I want completed Tasks hidden, so that the screen shows only what remains
4. As a Vikunja user, I want Tasks sorted by due date (soonest first, undated last), so that the most urgent are at the top
5. As a Vikunja user, I want Tasks with the same due date ordered by Priority (highest first), so that important work surfaces first
6. As a Vikunja user, I want each row to show "Project - Task", so that I know the context of each Task
7. As a Vikunja user, I want the due date shown under the Task name, so that I can see timing without clutter
8. As a Vikunja user, I want near due dates shown as "Today", "Tomorrow" or "Overdue Nd", so that I can read urgency instantly
9. As a Vikunja user, I want far due dates shown as an absolute date (e.g. "12 Nov"), so that distant deadlines are unambiguous
10. As a Vikunja user, I want Tasks without a due date to show no date line, so that no placeholder date appears
11. As a Vikunja user, I want a Priority icon on each Task, so that I can spot important work at a glance
12. As a Vikunja user, I want Priority collapsed into none (0-1), medium (2-3) and high (4-5), so that icons stay legible on e-ink
13. As a Vikunja user, I want about 8 rows shown, so that the screen stays readable
14. As a Vikunja user, I want a "+N more" footer when Tasks overflow, so that I know the list is truncated
15. As a Vikunja user, I want a "No open tasks" message when nothing is open, so that an empty screen is not mistaken for a fault
16. As a Vikunja user, I want a short error message when the API call fails, so that I know something is wrong
17. As a Vikunja user, I want to enter my Vikunja base URL as a setting, so that it works with my self-hosted instance
18. As a Vikunja user, I want to enter my API token as a setting, so that it is not hardcoded in the repo
19. As a Vikunja user, I want the token sent as a Bearer header, so that polling is authenticated securely
20. As a Vikunja user, I want the Recipe to refresh every 15 minutes, so that the display stays current without draining the battery
21. As a developer, I want to preview the Recipe locally with `trmnlp`, so that I can iterate without a device
22. As a developer, I want the Recipe importable into TRMNL, so that I can install and share it
23. As a developer, I want the repo to be template-only with no server, so that there is nothing to host
24. As a developer, I want the Recipe config-driven, so that later features (grouping by Project, filters, other layouts) are easy to add

## Implementation Decisions

- The deliverable is a TRMNL Recipe in `trmnlp` project layout, with the full layout only in v1.
- Data strategy is TRMNL Polling against the Vikunja API; the instance is publicly reachable.
- The request fetches the first page of open Tasks across all Projects from the Vikunja tasks endpoint. It filters to not-done and sorts server-side by due date ascending, then Priority descending. No multi-page fetching.
- Settings: Vikunja base URL and API token (encrypted custom field, sent as a Bearer header). No Project or filter setting in v1.
- Refresh interval default: 15 minutes.
- All shaping happens in Liquid: row cap (about 8), "+N more" count, relative-vs-absolute due labels, Priority-to-icon mapping, and unset-date handling (Vikunja's zero date `0001-01-01T00:00:00Z` means no due date).
- Priority levels: none (0-1), medium (2-3), high (4-5).
- Row format: "Project - Task" on the first line, due label beneath, Priority icon.
- Empty state shows "No open tasks"; API failure shows a short error message.
- The Recipe is built to be reshaped later: grouping Tasks under Projects, other layouts, and Project or saved-filter scoping are expected follow-ups.
- Domain terms follow `GLOSSARY.md`: Recipe, Task, Project, Priority.

## Testing Decisions

- A good test checks external behaviour only: rendered output for a given input, not template internals.
- Seam 1 (primary): render the full-layout template from a fixture Vikunja API response and a fixed "now". Assert row order, "Project - Task" text, due labels (Today, Tomorrow, Overdue, absolute, none), Priority icons per level, the 8-row cap, the "+N more" footer, and the empty and error messages.
- Seam 2: a static check of the polling config: URL built from the base URL setting, Bearer header from the token setting, not-done filter, sort order, and 15-minute interval.
- Prior art: none, as the repo is new.

## Out of Scope

- Grouping Tasks under Projects
- Layouts other than full
- Project or saved-filter scoping
- Multi-page fetching
- Webhook push or any server or script
- Editing Tasks or any write access to Vikunja
- Priority-level customisation

## Further Notes

- If Liquid proves too limiting for the date or sort logic, revisit adding a small shaping step.
- Vikunja's page size defaults to 50, which comfortably exceeds the 8 rows shown.
