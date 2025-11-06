# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an asdf plugin for managing Xcode versions using the xcodes CLI tool as a wrapper. The plugin allows users to install, list, and manage different Xcode versions through the asdf version manager, leveraging the xcodes tool for actual Xcode downloading and installation.

## Architecture

The plugin follows the standard asdf plugin structure:

- **`bin/`** - Core asdf hook scripts that asdf calls during plugin operations
  - `download` - Downloads Xcode .xip files using `xcodes download`
  - `install` - Uses xcodes to install Xcode and creates wrapper scripts
  - `list-all` - Lists all available Xcode versions using `xcodes list`
  - `latest-stable` - Determines the latest stable (non-beta) version
  - `list-bin-paths` - Tells asdf where to find executables (bin directory)
  - `exec-env` - Sets up environment for version switching (DEVELOPER_DIR)
- **`lib/utils.bash`** - Shared utility functions used across all bin scripts
- **`scripts/`** - Development tooling scripts for formatting and linting

## Development Commands

### Linting and Formatting
```bash
# Run shellcheck and shfmt linting
scripts/lint.bash

# Auto-format bash code with shfmt
scripts/format.bash
```

### Testing
```bash
# Test the plugin locally
asdf plugin test xcode https://github.com/ducvuongpham/asdf-xcode.git "xcodes --help"
```

### Prerequisites
```bash
# Install xcodes first (required dependency)
brew install xcodesorg/made/xcodes
```

## Key Implementation Details

### xcodes Integration
- Uses `xcodes list` to get available Xcode versions (including betas)
- Installation handled by `xcodes install` command with custom path
- Requires Apple ID authentication for Xcode downloads
- Supports both stable and beta versions
- **Fuzzy Version Matching:** Partial versions automatically resolve to latest match

### Fuzzy Version Matching
- **`26`** → resolves to latest `26.x.x` (e.g., `26.0.1`)
- **`26.0`** → resolves to latest `26.0.x` (e.g., `26.0.1`)
- **`16.2`** → returns exact match if available
- **Preference:** Stable releases > Release Candidate > GM > Beta
- **Error handling:** Invalid versions return clear error messages

### Installation Process
- Downloads Xcode .xip files using `xcodes download` in separate download phase
- Installs from downloaded .xip or directly using `xcodes install`
- Creates wrapper scripts (`xcode`, `xcrun`, `xcodebuild`) with dynamic `DEVELOPER_DIR`
- Each version gets its own isolated installation path under asdf
- Uses `xcodes select` to set system-wide active version when switching

### Version Switching
- **`exec-env` script:** Sets `DEVELOPER_DIR` when switching versions via asdf/mise
- **Dynamic wrappers:** Scripts check for asdf-set `DEVELOPER_DIR` first
- **Global selection:** Uses `xcodes select` to update system Xcode pointer
- **Seamless switching:** `mise use xcode@16.2` or `asdf local xcode 16.2` work correctly

### Configuration Variables
- `TOOL_NAME` - Set to "xcode"
- `TOOL_TEST` - Test command used to verify xcodes availability: "xcodes --help"

### Error Handling
- Uses `set -euo pipefail` for strict bash error handling
- Custom `fail()` function for consistent error reporting
- Checks for xcodes availability before any operations
- Validates successful Xcode installation

## Development Dependencies

The project uses asdf-managed tools defined in `.tool-versions`:
- `shellcheck 0.9.0` - Bash script linting
- `shfmt 3.6.0` - Bash code formatting

## Usage Examples

```bash
# Install the plugin
asdf plugin add xcode https://github.com/ducvuongpham/asdf-xcode.git

# List available Xcode versions
asdf list-all xcode

# Install latest Xcode version
asdf install xcode latest

# Install specific Xcode version
asdf install xcode 16.2.0

# Fuzzy version matching (NEW!)
mise use xcode@26          # → installs 26.0.1 (latest 26.x)
mise use xcode@26.0        # → installs 26.0.1 (latest 26.0.x)
mise use xcode@16          # → installs 16.4 (latest 16.x)

# Set global Xcode version
asdf global xcode 16.2.0

# Use with mise (alternative to asdf)
mise use -g xcode@16.2.0
```

## Important Notes

- **Requires xcodes:** Must install `brew install xcodesorg/made/xcodes` first
- **Apple ID required:** xcodes will prompt for Apple ID credentials during installation
- **Large downloads:** Xcode installations are several GB and can take significant time
- **macOS only:** This plugin only works on macOS systems
- **Storage space:** Each Xcode version requires ~10GB+ of disk space