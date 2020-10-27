<p align="center">
    <a href="https://semgrep.dev"><img src="semgrep.svg" height="100" alt="Semgrep logo"/></a>
</p>
<h3 align="center">
  Lightweight static analysis for many languages.
  </br>
  Find bugs and enforce code standards.
</h3>

<p align="center">
  <a href="#getting-started">Getting started</a>
  <span> · </span>
  <a href="#Examples">Examples</a>
  <span> · </span>
  <a href="#resources">Resources</a>
  <br/>
  <a href="#usage">Usage</a>
  <span> · </span>
  <a href="#contributing">Contributing</a>
  <span> · </span>
  <a href="#commercial-support">Commercial support</a>
</p>

<p align="center">
  <a href="https://formulae.brew.sh/formula/semgrep">
    <img src="https://img.shields.io/homebrew/v/semgrep?style=flat-square" alt="Homebrew" />
  </a>
  <a href="https://pypi.org/project/semgrep/">
    <img alt="PyPI" src="https://img.shields.io/pypi/v/semgrep?style=flat-square&color=blue">
  </a>
  <a href="https://r2c.dev/slack">
    <img src="https://img.shields.io/badge/slack-join-green?style=flat-square" alt="Issues welcome!" />
  </a>
  <a href="https://github.com/returntocorp/semgrep/issues/new/choose">
    <img src="https://img.shields.io/badge/issues-welcome-green?style=flat-square" alt="Issues welcome!" />
  </a>
  <a href="https://github.com/returntocorp/semgrep#readme">
    <img src="https://img.shields.io/github/stars/returntocorp/semgrep?label=GitHub%20Stars&style=flat-square" alt="1500+ GitHub stars" />
  </a>
  <a href="https://twitter.com/intent/follow?screen_name=r2cdev">
    <img src="https://img.shields.io/twitter/follow/r2cdev?label=Follow%20r2cdev&style=social&color=blue" alt="Follow @r2cdev" />
  </a>
</p>

Semgrep is a static analysis tool that excels at expressing code standards — without complicated queries — and surfacing bugs early in the development flow. Rules look like the code you’re searching without needing to understand abstract syntax trees or wrestle with regexes.

The [Semgrep Registry](https://semgrep.dev/explore) has 900+ rules written by the Semgrep community covering security, correctness, and performance bugs. No need to DIY unless you want to.

Semgrep runs offline, on uncompiled code.

| Go | Java | JavaScript | JSON | Python | Ruby (beta) | TypeScript (beta) | JSX (beta) | TSX (beta) |
| -- | ---- | ---------- | ---- | ------ | ----------- | ----------------- | ---------- | ---------- |
</br>

Visit [Semgrep Docs > Supported languages](https://dashboard.semgrep.dev/languages) for a complete up-to-date list.

## Getting started

Visit [Semgrep Docs > Getting started](https://semgrep.dev/docs/getting-started/) to get started.

## Examples

Visit [Semgrep Docs > Rule examples](https://semgrep.dev/docs/writing-rules/rule-ideas/) for use cases and ideas.

## Usage

### Command line options

See `semgrep --help` for command line options.

### Exit codes

`semgrep` may exit with the following exit codes:

- `0`: Semgrep ran successfully and found no errors
- `1`: Semgrep ran successfully and found issues in your code
- \>=`2`: Semgrep failed to run

### Upgrading

To upgrade, run the command below associated with how you installed Semgrep:

```sh
# Using Homebrew
$ brew upgrade semgrep

# Using pip
$ python3 -m pip install --upgrade semgrep

# Using Docker
$ docker pull returntocorp/semgrep:latest
```

## Contributing

Visit [Semgrep Docs > Contributing](https://semgrep.dev/docs/contributing/).

## Commercial support

Semgrep is a frontend to a larger program analysis library named [`pfff`](https://github.com/returntocorp/pfff/). `pfff` began and was open-sourced at [Facebook](https://github.com/facebookarchive/pfff) but is now archived. The primary maintainer now works at [r2c](https://r2c.dev). Semgrep was originally named `sgrep` and was renamed to avoid collisons with existing projects.

Semgrep is supported by [r2c](https://r2c.dev). We're hiring!

Interested in a fully-supported, hosted version of Semgrep? [Drop your email](https://forms.gle/dpUUvSo1WtELL8DW6) and we'll be in touch!
