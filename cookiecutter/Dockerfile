# Stage 1: Runtime
FROM python:3.12-slim

WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install cookiecutter
RUN pip install --no-cache-dir cookiecutter pytest pytest-cookies

# Create app directory
WORKDIR /app

# Copy source code
COPY src /app/src
COPY docker/scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# /workspace is where we will work (or /output)
WORKDIR /output

ENTRYPOINT ["entrypoint.sh"]
CMD ["python", "/app/src/generate.py"]
