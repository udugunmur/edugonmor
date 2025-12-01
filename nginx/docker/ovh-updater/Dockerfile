FROM python:3.9-slim

WORKDIR /app

COPY src/scripts/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/scripts/renew.py .

# Run the script every hour by default, or just once if overridden
CMD ["sh", "-c", "while true; do python renew.py; sleep 3600; done"]
