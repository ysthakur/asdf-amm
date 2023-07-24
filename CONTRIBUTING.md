# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

asdf plugin test amm https://github.com/ysthakur/asdf-amm.git "amm --version"
```

Tests are automatically run in GitHub Actions on push and PR.

`lib/utils.bash` is where everything happens. Inside it is a function `list_all_versions`
which lists all Ammonite versions by querying `https://api.github.com/repos/com-lihaoyi/Ammonite/releases`,
which returns a JSON array of all releases, and each release object has a list of
all its assets. Since Ammonite has different executables for each Scala version-Ammonite version pair,
it's necessary to go through all these assets instead of simply looking at the list
of tags. `list_all_versions` finds all assets with names in the form `x.x-x.x.x` (e.g. `2.12-2.5.9`),
and returns those.
