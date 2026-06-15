# action-lexicodegen

GitHub Actions for installing and running [Lexicodegen](https://github.com/charliewilco/Lexicodegen).

Use the root action when a workflow needs `lexicodegen` available on `PATH`:

```yaml
jobs:
  generate:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - uses: charliewilco/action-lexicodegen@v1
        with:
          version: v0.1.0

      - run: lexicodegen ./lexicons --output ./output/swift
```

Use the `/run` action when the workflow should install and invoke `lexicodegen` in one step:

```yaml
jobs:
  generate:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - uses: charliewilco/action-lexicodegen/run@v1
        with:
          version: v0.1.0
          sources: ./lexicons
          output: ./output/swift
```

Pinned versions are recommended for reproducible generated output. `version: latest` is supported for convenience, but downstream projects should prefer explicit Lexicodegen release tags.

## Setup Action

```yaml
- uses: charliewilco/action-lexicodegen@v1
  with:
    version: v0.1.0
```

Inputs:

| Name | Default | Description |
| --- | --- | --- |
| `version` | `latest` | Lexicodegen release tag to install. Accepts `v0.1.0` or `0.1.0`. |
| `install-dir` | `${{ runner.temp }}/lexicodegen` | Directory where the binary is installed. |
| `github-token` | `${{ github.token }}` | Token used for GitHub release API requests. |
| `verify` | `true` | Run `lexicodegen --version` after installation. |

Outputs:

| Name | Description |
| --- | --- |
| `path` | Installed binary path. |
| `version` | Full `lexicodegen --version` output. |

## Run Action

```yaml
- uses: charliewilco/action-lexicodegen/run@v1
  with:
    version: v0.1.0
    sources: |
      ./lexicons
      git-archive:https://github.com/example/lexicons/archive/refs/heads/main.tar.gz
    output: ./Generated/Lexicodegen
    extra-args: --allow-prefix app.bsky
```

Inputs:

| Name | Default | Description |
| --- | --- | --- |
| `version` | `latest` | Lexicodegen release tag to install. |
| `sources` | `./lexicons` | Newline-separated lexicon sources. Ignored when `config` is set. |
| `output` | `./output/swift` | Swift output directory passed as `--output`. |
| `config` | empty | Optional config file. When set, runs `lexicodegen --config <config>`. |
| `extra-args` | empty | Extra raw CLI arguments appended to the command. |
| `working-directory` | `.` | Directory where `lexicodegen` runs. |
| `install-dir` | `${{ runner.temp }}/lexicodegen` | Directory where the binary is installed. |
| `github-token` | `${{ github.token }}` | Token used for GitHub release API requests. |
| `verify` | `true` | Run `lexicodegen --version` after installation. |

## Release Tags

The action's major tags, such as `v1`, are for the action interface. The `version` input is the Lexicodegen CLI version to install.

After changing this action, publish a normal release tag and move the major tag:

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
git tag -fa v1 -m "Update v1"
git push origin v1 --force-with-lease
```
