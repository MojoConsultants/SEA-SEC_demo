# -----------------------------
# Stage 1: Build Go CLI (seaseq)
# -----------------------------
FROM golang:1.25.1 AS builder
WORKDIR /app

COPY go.mod ./
COPY . .

RUN go mod tidy && go mod download
RUN if [ -d "./cmd/sea-qa" ]; then \
      go build -o /bin/seaseq ./cmd/sea-qa ; \
    else \
      go build -o /bin/seaseq . ; \
    fi
RUN strip /bin/seaseq || true

# -----------------------------
# Stage 2: Python API + runners
# -----------------------------
FROM python:3.11-slim AS api
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends gcc && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Ensure dirs + logging
RUN mkdir -p /app/reports /var/log/sea-seq && \
    useradd -m seauser && \
    chown -R seauser:seauser /app /var/log/sea-seq
USER seauser

# Expose API port
EXPOSE 8000

# -----------------------------
# Stage 3: Final image
# -----------------------------
FROM api AS final

COPY --from=builder /bin/seaseq /usr/local/bin/seaseq

# Default to API
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

# Run CLI:
#   docker run --rm --entrypoint python myimage runner_cli.py scan --target example.com
#
# Run Report Generator:
#   docker run --rm --entrypoint python myimage runner_report.py
#
# Run API (default):
#   docker run -d -p 8000:8000 myimage
