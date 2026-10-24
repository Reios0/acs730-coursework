# Lab 4

## Image comparison

| Image | Base image                | Size     | Rebuild after 1-line code change |
|-------|---------------------------|----------|----------------------------------|
| naive | python:latest             | 1.15GB   |               4.601s             |
| slim  | python:3.12-slim-bookworm | 130MB    |               0.658s             |

- **Base image:** Most of the gap comes from the base image chosen in line 1. The difference between the two Python images is slightly over 1GB.
- **Dependency layer:** Yes, in the slim image only.
- **.dockerignore:** It kept .git, .github, __pycache__/, *.pyc, .pytest_cache/, evidence/, *.png, *.md, and Dockerfile* out of the build context.

## CI timings

| Measurement                  | Baseline | Cache miss | Cache hit | Worth it? |
|------------------------------|----------|------------|-----------|-----------|
| pip install step             |    3s    |     3s     |    1s     |    No     |
| docker build step            |    8s    |    14s     |    1s     |    No     |
| Whole workflow (wall clock)  |   53s    |  1min 15s  |  1min 2s  |    No     |

- **pip cache:** Not worth it. The cache hit saved 2s but it took 1s longer to setup Python.
- **docker cache:** Not worth it. The cache hit made the build faster but it took more time overall to set up the build and performing post run operations.

## Composite action vs. Reusable workflow

- **Composite (python-deps):** The dependency setup is a few steps that have to run on the same runner as pytest inside the test job, so it is packaged as an action that runs
as steps within a job I already have.
- **Reusable (docker-build):** The image build is a whole job with its own runner that needs write access which the test job does not, so it is packaged as a workflow where
the permission is granted only to the image job.
