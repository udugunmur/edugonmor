#!/bin/bash
set -e

# If arguments are provided, execute them directly (for testing/scripts)
if [ "$#" -gt 0 ]; then
    echo "🚀 Executing: $@"
    # Execute command but don't exit on failure so we still get the shell
    "$@" || echo "⚠️ Command failed with exit code $?"
    echo "🐚 Entering interactive shell..."
    exec /bin/bash
fi

# Default: Launch the interactive edugonmor shell
exec edugonmor
