# Contributing to @NAME@

Thank you for helping with Reika DE. These rules are the same in every
Reika repository.

## Language

Code, comments, commit messages, and documentation are written in American
English. User interface strings are written in `en-US` first and translated
through the project's translation files.

## Licensing

This repository is licensed under `@LICENSE@` (see `LICENSES/`). Every source
file starts with SPDX headers:

```
SPDX-FileCopyrightText: @YEAR@ ReikaDE contributors
SPDX-License-Identifier: @LICENSE@
```

Files that cannot carry a header are covered by `REUSE.toml`. CI runs
`reuse lint`. By contributing you agree that your work is released under the
same license.

Artwork under CC BY-NC 4.0 lives only in the asset repositories
(`reika-icons`, `reika-cursors`, `reika-wallpapers`, `reika-sounds`) and is
never compiled into another repository's binaries.

## AI assistance

AI-assisted contributions are welcome. You must understand what you submit,
have tested it, and accept responsibility for it as if you had written it
yourself. No per-commit marker is required here. Contributions to upstream
projects (Smithay, Avalonia, and others) follow the upstream's own policy;
Smithay, for example, requires disclosure in the commit message.

## Building

Every repository has a `justfile` with the same recipes:

| Recipe | Does |
| --- | --- |
| `just build` | Builds everything |
| `just test` | Runs the tests |
| `just run` | Runs the component for development, nested where it applies |
| `just install` | Installs into `$DESTDIR$PREFIX` (default `/usr/local`) |
| `just lint` | Runs the checks CI runs |

Shared versions (Smithay revision, Avalonia version) are pinned in
`reika-epoch/pins.env`; change them there, not here.

## Commits and pull requests

- One topic per pull request; keep commits focused and their messages
  descriptive (what changed and why).
- CI must pass: formatting, lints, tests, and the license check.
- Add a regression test for every bug fix where the bug can be reproduced
  automatically.
