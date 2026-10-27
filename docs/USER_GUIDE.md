# Vikunja Tasks for TRMNL: user guide

This Recipe shows your open [Vikunja](https://vikunja.io) Tasks on your TRMNL. You set it up entirely inside TRMNL and Vikunja; you don't need to run anything yourself.

## Install

1. Download `trmnl-vikunja-<version>.zip` from the [latest release](https://github.com/allan-t/trmnl-vikunja/releases/latest). Don't unzip it.
2. In TRMNL, go to **Plugins > Private Plugin**, add a new plugin and choose to import a Recipe from a zip file.
3. Add the plugin to a playlist so it shows on your device.

(A listing in TRMNL's Recipes directory is planned; this guide will then point there instead.)

## Connect to Vikunja

1. In Vikunja, open **Settings > API Tokens** and create a token with **read** access to **Tasks** and **Projects**.
2. In the plugin's settings in TRMNL, paste it into **Vikunja API token**.
3. **Vikunja base URL**: leave it blank if you use Vikunja Cloud (`https://app.vikunja.cloud`). If you self-host, enter your instance address, for example `https://vikunja.example.com`. A trailing slash is fine.
4. Save, then refresh the plugin preview.

## Settings

| Setting | What it does |
| --- | --- |
| Vikunja base URL | Where your Vikunja lives. Blank means Vikunja Cloud. |
| Vikunja API token | Lets the Recipe read your Tasks and Projects. |
| Projects to show | Type Project names separated by commas, for example `Home, Work`. Only Tasks from those Projects appear. Names aren't case sensitive. Leave empty to show every Project. A name that matches no Project is ignored. |
| Priority levels to show | Pick the Priorities to show (Unset, Low, Medium, High, Urgent, Do now). Hold <kbd>Ctrl</kbd> or <kbd>⌘</kbd> and click to pick several. Leave empty to show all. |
| Group by Project | On: Tasks sit under a header for each Project. Off: one list of `Project - Task` rows. |

## What you'll see

Open Tasks are sorted by due date, then by Priority. Tasks without a due date come last. Each row can show a Priority icon (`!` for Medium and High, `!!` for Urgent and Do now) and a due label such as *Today*, *Tomorrow*, *Overdue 2d* or a date.

The Recipe fills the space your layout has. Tasks that don't fit are left out, and the title bar says how many (for example *+7 more*). Bigger layouts show more Tasks.

| Full | Half horizontal |
| --- | --- |
| ![Full layout](screenshots/full-grouped.png) | ![Half horizontal layout](screenshots/half_horizontal-grouped.png) |
| **Half vertical** | **Quadrant** |
| ![Half vertical layout](screenshots/half_vertical-grouped.png) | ![Quadrant layout](screenshots/quadrant-grouped.png) |

## Limits

- The Recipe reads up to **50 open Tasks** per refresh, picked after your Priority filter. Projects are filtered after that, so if you have many open Tasks in Projects you've hidden, some Tasks in the Projects you show may not appear.
- The screen refreshes every 15 minutes.

## Troubleshooting

- **"Could not load tasks"**: the Base URL or API token is wrong, the token lacks read access to Tasks and Projects, or Vikunja can't be reached from the internet. Check the URL opens in a browser and create a fresh token.
- **"No open tasks"**: you have none, or your filters leave nothing. Clear **Projects to show** and **Priority levels to show** to check.
- **"No open tasks in the selected Projects"**: none of the names in **Projects to show** match a Project with open Tasks. Check the spelling.
- **Self-hosting**: your Vikunja must be reachable from TRMNL's servers, not only your home network.

Found a problem? [Open an issue](https://github.com/allan-t/trmnl-vikunja/issues).
