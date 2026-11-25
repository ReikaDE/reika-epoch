# reika-epoch

The meta repository of [Reika DE](https://github.com/ReikaDE), a Wayland
desktop environment: the component list, the versions every component shares,
repository templates, reusable CI workflows, and one entry point to build
everything.

## Layout

Components are separate repositories, checked out next to this one:

```
ReikaDE/
  reika-epoch/      this repository
  smithay/          fork, branch reika/main
  Avalonia/         fork, branch reika/main
  reika-comp/
  reika-toolkit/
  ...
```

Set `REIKA_ROOT` to use another directory.

| File | Contents |
| --- | --- |
| `components.list` | Every component: repository, kind (`rust`, `dotnet`, `assets`, `fork`), license, phase |
| `pins.env` | Shared versions: the Smithay fork revision, Avalonia and the Avalonia fork, NWayland, Tmds.DBus, the .NET SDK floor |
| `templates/` | Starting files for new repositories (`common` plus one directory per kind) |
| `.github/workflows/` | Reusable CI: `rust.yml`, `dotnet.yml`, `reuse.yml` |
| `templates/licenses/` | License texts copied into new repositories: GPL-3.0-or-later, MIT, CC-BY-NC-4.0, CC0-1.0 |

## Recipes

```sh
just status                 # components and their checkouts
just clone                  # clone missing components (or: just clone reika-comp)
just avalonia-feed          # build ReikaDE.Avalonia.Wayland into the local feed
just build                  # build every checkout (also: test, install)
just check-pins             # compare checkouts with pins.env
just new NAME KIND LICENSE  # create a component from the templates
```

## Forks

`ReikaDE/smithay` and `ReikaDE/Avalonia` keep their upstream names. In both,
each change sits on its own `reika/<topic>` branch from the pinned upstream
base (the form proposed upstream), and `reika/main` stacks all of them; Reika
builds against `reika/main` at the revision in `pins.env`.

- **smithay:** base `54cf9c10`; topics `reika/hdr-connector-properties`,
  `reika/drm-restore-state`, `reika/x11-fullscreen-monitors`.
- **Avalonia:** base `12.2.0` plus
  [AvaloniaUI/Avalonia#22945](https://github.com/AvaloniaUI/Avalonia/pull/22945)
  (`pr/22945`); topics `reika/layer-stretch-and-text-input`,
  `reika/text-input-any-role`, `reika/layer-activation`,
  `reika/layer-output-and-setters`, `reika/session-lock`. `reika/main` also
  carries `reika/`, the standalone build of `Avalonia.Wayland`.

Bumping a pin: rebase the topic branches onto the new base, rebuild
`reika/main`, update `pins.env`, run `just check-pins`, then update the
components.

## License

MIT, see `LICENSES/`. Each component states its own license.
