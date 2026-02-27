#!/bin/bash
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script must be run using 'source'"
    echo "Usage: source $0 [clean|force]"
    exit 1
fi

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
TARGET_DIR="$THIS_DIR/bin"
TARGET_PATH="$TARGET_DIR/shellcheck"

VERSION="v0.11.0"
URL="https://github.com/koalaman/shellcheck/releases/download/${VERSION}/shellcheck-${VERSION}.linux.x86_64.tar.xz"

case "$1" in
    clean)
        echo "Cleaning shellcheck installation..."
        rm -f "$TARGET_PATH"
        unalias shellcheck 2>/dev/null
        unset SHELLCHECK_EXE
        return 0
        ;;
    force)
        echo "Force flag detected. Removing existing binary..."
        rm -f "$TARGET_PATH"
        ;;
    *)
        # Default behavior
        ;;
esac

if [ ! -f "$TARGET_PATH" ]; then
    echo "Installing spellcheck to $TARGET_DIR ..."
    mkdir -p "$TARGET_DIR"
    if wget -qO "$TARGET_PATH.tar.xz" "$URL"; then
        tar -xf "$TARGET_PATH.tar.xz" -C "$TARGET_DIR" --strip-components=1 "shellcheck-${VERSION}/shellcheck"
        rm "$TARGET_PATH.tar.xz"
        echo "spellcheck installed successfully."
    else
        echo "Error: Failed to download spellcheck."
        return 1
    fi
else
    echo "spellcheck already installed"
fi

export SHELLCHECK_EXE="$TARGET_PATH"
alias shellcheck='$SHELLCHECK_EXE'
