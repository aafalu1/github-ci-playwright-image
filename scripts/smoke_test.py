#!/usr/bin/env python3
"""
Container Smoke Test:
Verifies that the Chromium browser engine
can launch successfully without missing OS shared libraries.
"""

import sys
from playwright.sync_api import sync_playwright

def run_smoke_test():
    print("[INFO] Starting headless Chromium smoke test.", flush=True)

    with sync_playwright() as p:
        print("[INFO] Launching Chromium...", flush=True)
        try:
            browser = p.chromium.launch(headless=True)
            try:
                page = browser.new_page()
                page.set_content("<html><body><h1>Container Ready</h1></body></html>")
                title_elem = page.locator("h1").inner_text()
                assert title_elem == "Container Ready", "DOM content mismatch"
                result = page.evaluate("() => 2 + 2")
                assert result == 4, "JS evaluation failed"
            finally:
                browser.close()
        except Exception as exc:
            print(f"[ERROR] Chromium smoke test failed: {exc}", file=sys.stderr, flush=True)
            sys.exit(1)

    print("[PASS] Chromium launched and DOM/JavaScript checks passed.", flush=True)


if __name__ == "__main__":
    run_smoke_test()
