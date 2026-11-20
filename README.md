# devcontainer-universal

A ready-to-use development image combining the Java, Node.js, and Go toolchains
from the `devcontainer-java`, `devcontainer-node`, and `devcontainer-go` images.
It is based on `letsdone/devcontainer-base:0.1.3-all` and supports
`linux/amd64` and `linux/arm64`.

## Included tools

- OpenJDK 21.0.2 and Maven 3.9.9
- Node.js 24.17.0
- Go 1.27.4
- Git and ripgrep
- Palantir Java formatter CLI (`~/palantir-cli.sh`)
- The shared base image's development tools and optional AI CLI installers

The default image runs as the `dev` user, uses `/home/dev/workspace` as its
working directory, and starts Zsh.

## Use

```sh
docker pull letsdone/devcontainer-universal:latest
docker run --rm -it -v "$PWD:/home/dev/workspace" letsdone/devcontainer-universal:latest
```

Versioned releases also publish `-claude`, `-gemini`, `-codex`,
`-claude-gemini`, `-codex-gemini`, and `-all` variants with the corresponding
CLI tools preinstalled. The un-suffixed version and `latest` tags do not
preinstall those CLIs.

## Build locally

```sh
docker build -t devcontainer-universal .
```

The image installs Node.js 24.17.0 as the initial nvm default and Go 1.27.4.
In Zsh, use `nvm install <version>` and `nvm use <version>` to install and
switch Node.js versions; `nvm alias default <version>` changes the default for
new Zsh sessions. Set `NODEJS_VERSION` or `GO_VERSION` with `--build-arg` to
choose the initial versions at build time. Set
`CLAUDE_PREINSTALLED`, `GEMINI_PREINSTALLED`, or `CODEX_PREINSTALLED` to `true`
to preinstall the corresponding CLI.

Pushing a Git tag triggers the multi-architecture Docker Hub release workflow.
