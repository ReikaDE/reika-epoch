# SPDX-FileCopyrightText: 2026 ReikaDE contributors
# SPDX-License-Identifier: MIT
#
# Drives every Reika DE checkout found next to this repository. Each
# component has the same recipes: build, test, run, install.

root := env("REIKA_ROOT", parent_directory(justfile_directory()))
org := env("REIKA_ORG", "https://github.com/ReikaDE")

default:
    @just --list

# Lists the components and whether each is checked out.
status:
    @scripts/components.sh "{{root}}" | while read -r name kind license phase; do \
        if [ -d "{{root}}/$name/.git" ]; then \
            printf '%-26s %-7s %-18s phase %s  %s\n' "$name" "$kind" "$license" "$phase" \
                "$(git -C "{{root}}/$name" rev-parse --abbrev-ref HEAD) $(git -C "{{root}}/$name" rev-parse --short HEAD)"; \
        else \
            printf '%-26s %-7s %-18s phase %s  (not checked out)\n' "$name" "$kind" "$license" "$phase"; \
        fi; \
    done

# Clones every listed component that is missing (or only those named).
clone *names:
    @scripts/components.sh "{{root}}" {{names}} | while read -r name _; do \
        [ -d "{{root}}/$name" ] || git clone "{{org}}/$name.git" "{{root}}/$name"; \
    done

# Runs a recipe in every checked-out component that has a justfile, in manifest order.
each recipe *names:
    @scripts/components.sh "{{root}}" {{names}} | while read -r name kind _; do \
        [ "$kind" != fork ] || continue; \
        [ -f "{{root}}/$name/justfile" ] || continue; \
        echo "==> $name: {{recipe}}"; \
        just --justfile "{{root}}/$name/justfile" --working-directory "{{root}}/$name" {{recipe}} || exit 1; \
    done

build *names: (each "build" names)
test *names: (each "test" names)
install *names: (each "install" names)

# Builds the Avalonia fork's package into the local feed the .NET components read.
avalonia-feed:
    git -C "{{root}}/Avalonia" checkout --quiet "$(. ./pins.env && echo "$AVALONIA_FORK_REV")"
    just --justfile "{{root}}/Avalonia/reika/justfile" --working-directory "{{root}}/Avalonia/reika" install

# Checks every checkout against pins.env.
check-pins:
    scripts/check-pins.sh "{{root}}"

# Creates a component from a template: just new reika-comp rust GPL-3.0-or-later
new name kind license:
    scripts/new-repo.sh "{{root}}" "{{name}}" "{{kind}}" "{{license}}"
