#!/bin/bash
# Setup local development hooks for FalcoClaw
# Run from repo root: ./scripts/setup-dev.sh

set -e

echo "Setting up FalcoClaw pre-commit hook..."

mkdir -p .git/hooks
cp .git/hooks/pre-commit .git/hooks/pre-commit 2>/dev/null || \
  ln -sf ../../.git/hooks/pre-commit .git/hooks/pre-commit

if [ -L .git/hooks/pre-commit ] || [ -f .git/hooks/pre-commit ]; then
    echo "Pre-commit hook installed"
    echo "   Run 'make ci-check' to test manually"
    echo "   Hooks run automatically on every 'git commit'"
else
    echo "Failed to install hook"
    exit 1
fi
