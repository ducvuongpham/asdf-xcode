#!/usr/bin/env bash

set -euo pipefail

TOOL_NAME="xcode"
TOOL_TEST="xcodes --help"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

ensure_xcodes_installed() {
	if ! command -v xcodes &>/dev/null; then
		fail "xcodes is not installed. Please install it first with: brew install xcodesorg/made/xcodes"
	fi
}

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_all_versions() {
	ensure_xcodes_installed
	# Get all available Xcode versions from xcodes (includes betas by default)
	# Format: "16.2 (16C5032a)" or "16.2 Beta (16C5013f)"
	xcodes list | awk '{print $1}' | grep -E '^[0-9]+\.[0-9]+' | sort -V | uniq
}

download_release() {
	local version="$1"
	local filename="$2"

	echo "* Downloading $TOOL_NAME release $version..."

	# Extract the directory from the filename path
	local download_dir
	download_dir="$(dirname "$filename")"

	# Create the download directory if it doesn't exist
	mkdir -p "$download_dir"

	ensure_xcodes_installed

	echo "* This may require your Apple ID credentials and can take a while..."

	# Use xcodes to download the Xcode .xip file
	xcodes download "$version" --directory "$download_dir" || fail "Failed to download Xcode $version"

	echo "* Xcode $version downloaded successfully to $download_dir"
}

download_xcode_version() {
	local version="$1"
	local download_path="$2"

	download_release "$version" "$download_path/dummy.xip"
}

install_xcode_version() {
	local version="$1"
	local install_path="$2"

	ensure_xcodes_installed

	echo "* Installing Xcode $version using xcodes..."
	echo "* Looking for downloaded Xcode files in $ASDF_DOWNLOAD_PATH..."

	# Use xcodes to install from the downloaded file
	# xcodes install expects a directory, not a full path to .app
	local xcode_install_dir="${install_path%/*}"
	mkdir -p "$xcode_install_dir"

	# Check if there's a downloaded .xip file to use
	local xip_file=$(find "$ASDF_DOWNLOAD_PATH" -name "*.xip" -type f | head -n1)
	if [[ -n "$xip_file" ]]; then
		echo "* Installing from downloaded file: $xip_file"
		xcodes install --path "$xip_file" --directory "$xcode_install_dir" || fail "Failed to install Xcode $version from downloaded file"
	else
		echo "* No downloaded file found, installing directly..."
		xcodes install "$version" --directory "$xcode_install_dir" || fail "Failed to install Xcode $version"
	fi

	# xcodes creates Xcode-X.Y.Z.app, we need to find and rename it to Xcode.app
	local installed_app=$(find "$xcode_install_dir" -name "Xcode*.app" -type d | head -n1)
	if [[ -n "$installed_app" && "$installed_app" != "$install_path/Xcode.app" ]]; then
		mv "$installed_app" "$install_path/Xcode.app"
	fi

	echo "* Xcode $version installed successfully to $install_path"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		# Install Xcode using xcodes
		install_xcode_version "$version" "$install_path"

		# Create a wrapper script for xcode command
		mkdir -p "$install_path"
		cat >"$install_path/xcode" <<EOF
#!/usr/bin/env bash
# Xcode $version wrapper script
export DEVELOPER_DIR="$install_path/Xcode.app/Contents/Developer"
exec "\$DEVELOPER_DIR/usr/bin/xcodebuild" "\$@"
EOF
		chmod +x "$install_path/xcode"

		# Also create xcrun wrapper
		cat >"$install_path/xcrun" <<EOF
#!/usr/bin/env bash
# xcrun wrapper for Xcode $version
export DEVELOPER_DIR="$install_path/Xcode.app/Contents/Developer"
exec "\$DEVELOPER_DIR/usr/bin/xcrun" "\$@"
EOF
		chmod +x "$install_path/xcrun"

		echo "$TOOL_NAME $version installation was successful!"
		echo "You can now use: xcode, xcrun, or set DEVELOPER_DIR=$install_path/Xcode.app/Contents/Developer"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
