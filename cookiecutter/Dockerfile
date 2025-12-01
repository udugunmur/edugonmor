# Stage 1: Runtime
FROM python:3.12-slim

WORKDIR /workspace

# Install system dependencies
# git is required by cookiecutter/copier often
RUN apt-get update && apt-get install -y \
    git \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install cookiecutter
RUN pip install --no-cache-dir cookiecutter pytest pytest-cookies

# Create entrypoint directory
WORKDIR /app

# Copy entrypoint script if exists (will be created later)
COPY docker/scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Environment variables
ENV PYTHONUNBUFFERED=1

# /workspace is where we will work (mount point)
WORKDIR /workspace

ENTRYPOINT ["entrypoint.sh"]
CMD ["/bin/bash"]
