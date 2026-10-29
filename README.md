# Swedish Standards Rail

This folder is a custom configuration root for Bentley OpenRail Designer.

## Install with the BAT file

Run `Installera_OpenRail_Konfig.bat` and enter the installed OpenRail year (default
2026). You can also run `Installera_OpenRail_Konfig.bat 2026`.

The installer uses `Swedish Standards Rail.zip` beside the BAT if present.
Otherwise it downloads this repository's `main` archive using the `URL` setting
near the top of the BAT. That URL requires the configuration pull request to have
been merged. For a fixed release archive, you can also set its `SHA256` there.
Flat ZIPs and GitHub ZIPs containing a wrapping folder are supported.
Downloads show a progress bar with the downloaded size and, when the server
provides a total size, the percentage complete.

Files are installed in `C:\Swedish Standards Rail`. Existing extra files and
WorkSets are retained. Changed files are backed up under `_installer-backups`,
and a copy failure rolls back files changed by that run. If needed, Windows asks
for administrator access only for copying configuration files into `C:\`.
When all 18 replacement NCAD libraries are present in the package, updates also
back up and retire the seven supplied stock LVA resources. Incomplete packages
leave those resources in place. Unrelated additional files remain untouched.

The installer then opens the current user's existing
`%LOCALAPPDATA%\Bentley\OpenRailDesigner\26.0.0\prefs\configuration.xml`
and adds the custom configuration. Other OpenRail years use the matching version
folder, such as `25.0.0` for 2025. This XML step runs as the original user even if
file installation needed administrator access.

Existing configurations, their settings, and the current selection are preserved.
If the same folder is already registered, no duplicate is added. The previous
default name **Swedish Standards Rail** is renamed to **BJP26**, preserving its
other settings; other existing names are kept. Changed XML is backed up beside
the original before an atomic replacement. Invalid or unsupported XML is
rejected without overwriting it.
If no XML exists, the installer creates one and keeps Bentley examples available
when their installed folder exists. Close OpenRail before running the installer.

The ZIP does not need a preferences XML: any bundled `configuration.xml`, `prefs`
folder, or `ConfigurationSetup.cfg` is skipped. After installation, select
**BJP26** in OpenRail's configuration list. An existing entry with a custom name
for the same path keeps that name.

## Load in OpenRail

1. Open **Manage Configuration** on OpenRail's start screen.
2. Add a configuration named **BJP26** with the folder path
   `C:\Swedish Standards Rail\` (select this root, not WorkSpaces or Organization-Civil).
3. Select that configuration, then WorkSpace **Swedish Standards** and WorkSet
   **Swedish Rail**, or create a new WorkSet for your project.
4. Create a new design file. The default is `Seed2D - Metric Rail Design.dgn`.

The folder paths follow `_USTN_CONFIGURATION`. To relocate the configuration,
move/copy the entire folder and add the new location in Manage Configuration.
Bentley's installed ConfigurationSetup.cfg does not need to be edited for this method.

## Contents and defaults

- `WorkSpaceSetup.cfg` connects the configuration root, Civil standards, WorkSpaces,
  WorkSets, and the creation templates.
- `WorkSpaces/Swedish Standards.cfg` loads the Swedish organization standards and
  allows project-independent WorkSpace overrides.
- `Organization-Civil/Swedish Standards.cfg` loads the supplied metric resources,
  rail feature libraries, TRV sheet seeds, fonts, line styles, macros, and printers.
- `WorkSpaces/Swedish Standards/WorkSets/Swedish Rail.cfg` is a starter WorkSet;
  project files go in its `Swedish Rail/Dgn` folder.
- `WorkSpaces/Template` contains Bentley's creation templates, with the malformed
  superelevation condition corrected. New WorkSets can override the template library
  and design seed using the variables documented in their CFG files.
- `Organization/standards.cfg` is available for future company-wide additions.
- `Organization-Civil/LVA.cfg` loads the local NCAD LVA libraries in the original
  **Swedish Standards** WorkSpace and **Swedish Rail** WorkSet. Six disciplines
  supply 18 active libraries; experimental Signal libraries are included but
  disabled by default. The stock LVA resources are removed from the package.
  See `Organization-Civil/LVA/README.md`.

The existing `OpenRail Templates Metric.itl` default is preserved. The supplied
TRV template libraries remain available to choose in OpenRail. Rail dimensions,
cant settings, seed model names, and the contents of binary design libraries are
preserved. The invalid imperial superelevation rule reference now uses the supplied
`AASHTO_2018_metric.xml`; this is the existing AASHTO road rule, not a Swedish rail
design rule. SmartObjects is loaded only if its optional MVBA is supplied.

Original CFG files are retained under `_backup`. That folder is outside the active
configuration search paths.

## Validation

The installed OpenRail Designer 2026 configuration parser successfully loaded this
configuration, the Swedish WorkSpace, and the starter WorkSet. Referenced seeds,
templates, lookup workbooks, macros, and resource lists were checked on disk.
Binary library contents, embedded references, macro execution, and drawing
creation still need an in-application check.

Run the installer regression checks in Windows PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Installer.Tests.ps1
```

These checks use isolated temporary folders. They cover existing XML entry and
selection preservation, BJP26 naming and migration, repeated installs, name
collisions, new profiles, malformed XML, ZIP layouts and exclusions, traversal
rejection, the BAT and administrator entry points, LVA migration, backups and
rollback, including a locked stock library during migration.
Local `_backup`, `_validation`, `_installer-backups`, preferences, and generated
ZIPs are excluded from Git.

## References

- [Bentley: Adding a custom configuration through Manage Configuration](https://bentleysystems.service-now.com/community?id=kb_article&sysparm_article=KB0018832)
- [Bentley: Generating an MSDebug configuration report](https://bentleysystems.service-now.com/community?id=kb_article&sysparm_article=KB0108491)
