ARG PYTHON_VERSION=3.11

FROM python:${PYTHON_VERSION}-slim-bookworm

LABEL description="Python + Behave + Playwright Chromium CI Image"

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    APP_ENV=ci \
    APP_HEADLESS=true \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

COPY requirements.txt /tmp/requirements.txt

RUN python -m pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt && \
    python -m playwright install --with-deps chromium && \
    rm -f /tmp/requirements.txt

RUN mkdir -p /workspace /reports && \
    chmod 1777 /workspace /reports && \
    chmod -R a+rX /ms-playwright

COPY scripts/ /usr/local/bin/scripts/
RUN chmod +x /usr/local/bin/scripts/*.sh

WORKDIR /workspace

CMD ["/bin/bash", "-c", "echo '[INFO] Python + Playwright Chromium test image ready'; python --version; playwright --version; behave --version"]