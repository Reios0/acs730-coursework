# Lab 4

## Image comparison

| Image | Base image                | Size     | Rebuild after 1-line code change |
|-------|---------------------------|----------|----------------------------------|
| naive | python:latest             | 1.15GB   |               4.601s             |
| slim  | python:3.12-slim-bookworm | 130MB    |               0.658s             |

- **Base image:** Most of the gap comes from the base image chosen in line 1. The difference between the two Python images is slightly over 1GB.
- **Dependency layer:** Yes, in the slim image only.
- **.dockerignore:** It kept .git, .github, __pycache__/, *.pyc, .pytest_cache/, evidence/, *.png, *.md, and Dockerfile* out of the build context.

