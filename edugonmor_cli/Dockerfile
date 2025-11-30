# Multi-stage build for the CLI tool
# https://docs.docker.com/build/building/multi-stage/
#
# Usage:
#   docker run -it --rm -v $(pwd):/workspace edugonmor-cli create project my-api
#

# Stage 1: Build
FROM python:3.12-slim AS builder

WORKDIR /app

# Install build dependencies
RUN pip install --no-cache-dir hatchling

# Copy project files
COPY pyproject.toml README.md ./
COPY src/ ./src/
COPY template/ ./template/

# Build wheel
RUN pip wheel --no-deps --wheel-dir /wheels .

# Stage 2: Runtime
FROM python:3.12-slim AS runtime

WORKDIR /workspace

# Install system dependencies (git required by Copier)
RUN apt-get update && apt-get install -y \
    git \
    make \
    && rm -rf /var/lib/apt/lists/*

# Configure git for generated projects
RUN git config --global user.email "cli@edugonmor.com" && \
    git config --global user.name "edugonmor-cli" && \
    git config --global init.defaultBranch main

# Copy wheel from builder
COPY --from=builder /wheels/*.whl /wheels/

# Install the CLI with dev dependencies (pytest, ruff)
RUN pip install --no-cache-dir /wheels/*.whl && rm -rf /wheels
RUN pip install --no-cache-dir pytest pytest-cov ruff

# Copy template (needed at runtime)
COPY template/ /app/template/

# Copy entrypoint script
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Environment variables
ENV DEFAULT_TEMPLATE_PATH=/app/template
ENV OUTPUT_DIR=/workspace

# /workspace is where user mounts their local directory
VOLUME /workspace

ENTRYPOINT ["entrypoint.sh"]
CMD ["/bin/bash"]
