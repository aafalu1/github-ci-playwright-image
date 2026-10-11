# ==============================================================================
# GitHub Actions Runner Image: Playwright Python POM Automation Framework
# Built on Microsoft Official Base: Pre-bakes Chromium to eliminate CDN download timeouts
# ==============================================================================

FROM mcr.microsoft.com/playwright/python:v1.40.0-jammy

LABEL description="Python + Behave + Playwright Chromium CI Image"

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    APP_ENV=ci \
    APP_HEADLESS=true \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

WORKDIR /workspace

COPY requirements.txt /tmp/requirements.txt

# 1. Automatic pip upgrade & 2. Install latest dependencies from requirements.txt
RUN python -m pip install --upgrade pip && \
    pip install --upgrade -r /tmp/requirements.txt && \
    rm -f /tmp/requirements.txt

# Ensure workspace, reports, and browser caches have full permissions for GitHub Actions runner
RUN mkdir -p /workspace /reports && \
    chmod 1777 /workspace /reports && \
    chmod -R 777 /ms-playwright

COPY scripts/ /usr/local/bin/scripts/
RUN chmod +x /usr/local/bin/scripts/*.sh || true

CMD ["/bin/bash", "-c", "echo '[INFO] Python + Playwright Chromium test image ready'; python --version; playwright --version; behave --version"]