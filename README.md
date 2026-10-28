# trmnl-vikunja

Show your open [Vikunja](https://vikunja.io) tasks on your [TRMNL](https://trmnl.com) e-ink display.

![Full layout](docs/screenshots/full-grouped.png)

- Works with Vikunja Cloud and self-hosted Vikunja (2.4.0 or newer).
- Fits all four TRMNL layouts: full, half horizontal, half vertical and quadrant.
- Filter by project and priority, or write your own Vikunja filter.
- Group tasks by project, sort them, and see priority icons and due labels (*Today*, *Overdue 2d*).

## Quick start

1. Download `trmnl-vikunja-<version>.zip` from the [latest release](https://github.com/allan-t/trmnl-vikunja/releases/latest). Don't unzip it.
2. In TRMNL, go to **Plugins > Private Plugin**, add a new plugin and import the zip as a Recipe.
3. In Vikunja, create an API token under **Settings > API Tokens** with read access to **Tasks** and **Projects**.
4. Paste the token into the plugin's **Vikunja API token** setting. If you self-host, also set **Vikunja base URL**.
5. Add the plugin to a playlist.

The [user guide](docs/USER_GUIDE.md) covers every setting, custom filters, limits and troubleshooting.

## Help and contact

Something not working? Check [Troubleshooting](docs/USER_GUIDE.md#troubleshooting). For questions, bugs or ideas, [open an issue](https://github.com/allan-t/trmnl-vikunja/issues) on the [GitHub project](https://github.com/allan-t/trmnl-vikunja).

## Contributing

To run, test or change the Recipe, see [CONTRIBUTING.md](CONTRIBUTING.md).
