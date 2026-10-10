# Python + Playwright Chromium Container Image

This project builds one reusable Linux container image containing Python, the
project's Python test dependencies, and the Playwright **Chromium** browser.
Firefox and WebKit are intentionally not installed. The same `Dockerfile` can
be published to the GitLab Container Registry, GitHub Container Registry
(GHCR), or both.

## Image contents

- Python 3.11 on Debian Bookworm (`PYTHON_VERSION` can be overridden at build
  time).
- Dependencies from [`requirements.txt`](requirements.txt), including the
  pinned Playwright Python package.
- The matching Playwright Chromium binary and its required Linux packages.
- Verification scripts in `/usr/local/bin/scripts/`.
- Writable `/workspace` and `/reports` directories for CI jobs.

Docker is **not** installed in the resulting test image. Docker is only used by
the image-building pipeline (and is optional for local builds); jobs that
consume the published image do not need Docker-in-Docker.

The Python Playwright package version in `requirements.txt` must stay aligned
with the Playwright browser installed during the image build. Do not update one
without updating and verifying the other.

## Build and verify locally

Local image-build requirement: Docker with BuildKit/buildx enabled. This is not
a requirement for CI jobs that use the already-published image.

```bash
make build
make test
```

Equivalent Docker commands:

```bash
docker build -t playwright-python:local .
docker run --rm playwright-python:local /usr/local/bin/scripts/verify_image.sh
```

The verification script prints the Python and dependency versions, then
launches Chromium and runs a small DOM/JavaScript check. It fails with a
non-zero exit code if a required dependency or browser check fails.

## Publish to GitLab Container Registry

1. Push this project to GitLab and enable **Settings → General → Visibility,
   project features, permissions → Container Registry**.
2. Ensure the runner supports Docker-in-Docker and privileged execution as
   required by your GitLab runner configuration.
3. The included [`.gitlab-ci.yml`](.gitlab-ci.yml) logs into the built-in
   registry using GitLab CI variables, builds and tags the image, verifies it,
   and publishes branch/SHA tags. The default branch also publishes `latest`
   and `py3.11-pw1.40.0`; tagged releases publish the corresponding Git tag.

Use the published image from a GitLab pipeline:

```yaml
default:
  image: registry.gitlab.com/<namespace>/<image-project>:latest

test:
  script:
    - python --version
    - playwright --version
    - behave
```

If the consumer project is private or in another GitLab project, configure
Container Registry token access so its CI job can pull this image. See GitLab's
[CI job token documentation](https://docs.gitlab.com/ci/jobs/ci_job_token/).

## Publish to GitHub Container Registry

The [`.github/workflows/publish-image.yml`](.github/workflows/publish-image.yml)
workflow builds this same Dockerfile, runs the Chromium verification, and then
pushes the image to GHCR. Enable Actions for the repository and allow the
workflow's `GITHUB_TOKEN` to write packages (the workflow requests
`packages: write` permission).

It publishes branch and commit-SHA tags on pushes, `latest` on the default
branch, and version tags for Git tags such as `v1.2.3`. Pull requests build and
verify the image but do not publish it. The resulting image address is:

```text
ghcr.io/<owner>/<repository>:latest
```

### Use the GHCR image in a GitHub Actions job

For a public GHCR package:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/<owner>/<repository>:latest
    steps:
      - uses: actions/checkout@v4
      - run: python --version && playwright --version
      - run: behave
```

For a private package, provide credentials in the `container` configuration
using a package-read token stored as a GitHub Actions secret:

```yaml
    container:
      image: ghcr.io/<owner>/<repository>:latest
      credentials:
        username: ${{ github.actor }}
        password: ${{ secrets.GHCR_READ_TOKEN }}
```

Using a container image in a GitHub Actions job does not require creating a
separate GitHub Action. A custom JavaScript or Docker-based Action is a
different product interface; build one only if reusable action inputs/outputs
are needed.

## Local use with a test project

```bash
docker run --rm \
  -v "$PWD/../your-tests:/workspace" \
  -w /workspace \
  playwright-python:local \
  behave --tags=@smoke
```

The image's default command prints the Python, Playwright, and Behave versions.
When using it as a CI job image, the runner supplies the test command instead.
