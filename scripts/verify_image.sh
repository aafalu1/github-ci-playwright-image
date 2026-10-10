#!/usr/bin/env bash
# ==============================================================================
# Container Image Verification Script
# Validates Python version, installed dependencies, and browser engines
# ==============================================================================

set -euo pipefail

echo "========================================================"
echo "[INFO] Python + Playwright Chromium image verification"
echo "========================================================"

echo "[1/4] Python runtime"
python3 --version
python3 -c "import sys; print(f'Python executable: {sys.executable}')"
python3 -c "import sys; assert sys.version_info >= (3, 10), 'Python version must be >= 3.10'"
echo "[PASS] Python version satisfies the minimum supported version."

echo "[2/4] Python dependencies"
python3 -c "from importlib.metadata import version; print(f'  ✓ Playwright version: {version(\"playwright\")}')"
python3 -c "from importlib.metadata import version; print(f'  ✓ Behave version: {version(\"behave\")}')"
python3 -c "from importlib.metadata import version; print(f'  ✓ Pydantic version: {version(\"pydantic\")}')"
python3 -c "import pydantic_settings; print('  ✓ pydantic-settings: loaded')"
python3 -c "import behave_html_pretty_formatter; print('  ✓ behave-html-pretty-formatter: loaded')"

echo "[3/4] Playwright browser installation"
playwright --version
if [ ! -d "${PLAYWRIGHT_BROWSERS_PATH:-/ms-playwright}" ]; then
    echo "[ERROR] Playwright browser directory not found: ${PLAYWRIGHT_BROWSERS_PATH:-/ms-playwright}" >&2
    exit 1
fi
echo "[INFO] Browser files:"
find "${PLAYWRIGHT_BROWSERS_PATH:-/ms-playwright}" -maxdepth 1 -mindepth 1 -type d -print

echo "[4/4] Headless Chromium smoke test"
python3 /usr/local/bin/scripts/smoke_test.py

echo "[PASS] All container image verification checks passed."
