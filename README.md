<div align="center">

# asdf-amm [![Build](https://github.com/ysthakur/asdf-amm/actions/workflows/build.yml/badge.svg)](https://github.com/ysthakur/asdf-amm/actions/workflows/build.yml) [![Lint](https://github.com/ysthakur/asdf-amm/actions/workflows/lint.yml/badge.svg)](https://github.com/ysthakur/asdf-amm/actions/workflows/lint.yml)

[Ammonite](https://ammonite.io/) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

## Why use this?

The official instructions for installing Ammonite involve downloading the executable
for your desired version into a folder like `/usr/local/bin`, but this means you can
only have one version of Ammonite accessible at a time, and both installation and
updating are a bit annoying. asdf lets you install multiple versions of tools such
as Ammonite at a time, and you can switch between them automatically, in case you
need different Ammonite versions in different projects.

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `grep`, `awk`, `sed`: generic POSIX utilities.

# Install

Plugin:

```shell
asdf plugin add amm
# or
asdf plugin add amm https://github.com/ysthakur/asdf-amm.git
```

Ammonite:

```shell
# Show all installable versions
asdf list-all amm

# Install specific version
asdf install amm latest

# Set a version globally (on your ~/.tool-versions file)
asdf global amm latest

# Now Ammonite commands are available
amm --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

<!-- [Thanks goes to these contributors](https://github.com/ysthakur/asdf-amm/graphs/contributors)! -->

# License

See [LICENSE](LICENSE) © [ysthakur](https://github.com/ysthakur/)
