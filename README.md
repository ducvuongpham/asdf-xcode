<div align="center">

# asdf-xcode [![Build](https://github.com/ducvuongpham/asdf-xcode/actions/workflows/build.yml/badge.svg)](https://github.com/ducvuongpham/asdf-xcode/actions/workflows/build.yml) [![Lint](https://github.com/ducvuongpham/asdf-xcode/actions/workflows/lint.yml/badge.svg)](https://github.com/ducvuongpham/asdf-xcode/actions/workflows/lint.yml)

[xcode](https://github.com/ducvuongpham/asdf-xcode) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash` and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html)
- `xcodes`: Install with `brew install xcodesorg/made/xcodes`
- Apple ID account for Xcode downloads
- macOS system (Xcode is macOS-only)

# Install

Plugin:

```shell
asdf plugin add xcode
# or
asdf plugin add xcode https://github.com/ducvuongpham/asdf-xcode.git
```

xcode:

```shell
# Show all installable versions
asdf list-all xcode

# Install specific version
asdf install xcode latest

# Set a version globally (on your ~/.tool-versions file)
asdf global xcode latest

# Now xcode commands are available (via wrapper scripts)
xcode --help
xcrun --help

# Or use with mise
mise use -g xcode@16.2.0
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/ducvuongpham/asdf-xcode/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [tada](https://github.com/ducvuongpham/)
