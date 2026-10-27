# TRMNL Vikunja

A TRMNL Recipe that displays Vikunja tasks on a TRMNL e-ink device.

## Language

**Recipe**:
The shareable, importable TRMNL plugin this repo delivers.
_Avoid_: Plugin, app, widget

**Task**:
A single Vikunja item to be done, belonging to one Project.
_Avoid_: Todo, ticket, item

**Project**:
A Vikunja container that groups Tasks.
_Avoid_: List, board

**Priority**:
A Vikunja Task's importance, from 0 (unset) to 5, shown on the display as an icon.
_Avoid_: Urgency, importance

**Mode**:
How the Recipe chooses which Tasks to show: standard (Projects and Priority settings) or custom filter.
_Avoid_: Source, type

**Custom filter**:
A filter written by the user in Vikunja's filter syntax that alone decides which Tasks are shown, replacing the Project and Priority settings.
_Avoid_: Saved filter, query
