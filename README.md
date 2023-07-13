<div align="center">

# asdf-amm [![Build](https://github.com/ysthakur/asdf-amm/actions/workflows/build.yml/badge.svg)](https://github.com/ysthakur/asdf-amm/actions/workflows/build.yml) [![Lint](https://github.com/ysthakur/asdf-amm/actions/workflows/lint.yml/badge.svg)](https://github.com/ysthakur/asdf-amm/actions/workflows/lint.yml)

[amm](https://ammonite.io/) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add amm
# or
asdf plugin add amm https://github.com/ysthakur/asdf-amm.git
```

amm:

```shell
# Show all installable versions
asdf list-all amm

# Install specific version
asdf install amm latest

# Set a version globally (on your ~/.tool-versions file)
asdf global amm latest

# Now amm commands are available
amm --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/ysthakur/asdf-amm/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [ysthakur](https://github.com/ysthakur/)
