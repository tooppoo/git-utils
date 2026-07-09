# git-utils

## Installation

Each helper is installed as a `git-*` executable script.
When the install directory is in `PATH`, Git can run the helper as a Git subcommand.

For example, installing `git-commits-since-tag` makes the following command available:

```sh
git commits-since-tag v1.0.0
```

### Install selected helpers

Pass one or more helper names to the installer.

```sh
curl -fsSL https://raw.githubusercontent.com/tooppoo/git-helpers/main/install.sh \
  | sh -s -- git-commits-since-tag git-merges-since-tag
```

The installer downloads each requested script from `bin/<helper-name>` and installs it into:

```text
~/.local/bin
```

Helpers are installed in the order specified.

### Custom install directory

Set `INSTALL_DIR` to install the helpers somewhere else.

```sh
curl -fsSL https://raw.githubusercontent.com/tooppoo/git-helpers/main/install.sh \
  | INSTALL_DIR="$HOME/bin" sh -s -- git-commits-since-tag
```

Make sure the install directory is included in `PATH`.

```sh
export PATH="$HOME/.local/bin:$PATH"
```

### Install from a specific ref

By default, the installer downloads helpers from `main`.
Set `REF` to install from a tag, branch, or commit.

```sh
curl -fsSL https://raw.githubusercontent.com/tooppoo/git-helpers/main/install.sh \
  | REF=v0.1.0 sh -s -- git-commits-since-tag
```

For reproducible setup, prefer installing from a tagged release.

### Overwrite existing files

The installer does not overwrite an existing different file by default.
Use `--force` only when replacing an existing helper is intended.

```sh
curl -fsSL https://raw.githubusercontent.com/tooppoo/git-helpers/main/install.sh \
  | sh -s -- --force git-commits-since-tag
```
