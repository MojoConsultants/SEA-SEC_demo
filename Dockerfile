FROM python:3.11-slim
RUN useradd -m seauser
WORKDIR /app
COPY . /app
RUN mkdir -p /app/reports /var/log/sea-seq && chown -R seauser:seauser /app/reports /var/log/sea-seq
USER seauser
CMD ["python", "runner.py"]




# -----------------------------
# Stage 1: Build Go CLI (seaseq)
# -----------------------------
FROM golang:1.25.1 AS builder
WORKDIR /app

# Copy go.mod first (helps cache dependencies)
COPY go.mod ./

# Copy entire project (brings in go.sum if present, source code, tests, etc.)
COPY . .

# Ensure dependencies are up to date (regenerates go.sum if missing)
RUN go mod tidy && go mod download

# Build CLI binary (works if main.go is in ./cmd/sea-qa OR repo root)
RUN if [ -d "./cmd/sea-qa" ]; then \
      go build -o /bin/seaseq ./cmd/sea-qa ; \
    else \
      go build -o /bin/seaseq . ; \
    fi

# Strip binary to reduce size
RUN strip /bin/seaseq || true

# -----------------------------
# Stage 2: Python API service
# -----------------------------
FROM python:3.11-slim AS api
WORKDIR /app

# Install system deps for building Python packages
RUN apt-get update && apt-get install -y --no-install-recommends gcc && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY . .

# Expose FastAPI port
EXPOSE 8000

# -----------------------------
# Stage 3: Final image (Default Mode Runs runner.py)
# -----------------------------
FROM api AS final

# Copy CLI binary from builder
COPY --from=builder /bin/seaseq /usr/local/bin/seaseq

# Default entrypoint → FastAPI service
CMD ["python", "runner.py"]
# To run API service instead, use default entrypoint, e.g.:
  docker run --rm myimage python runner.py

  

# To run CLI instead, override entrypoint, e.g.:
# docker run --rm --entrypoint seaseq <image_name> --help

docker run -d --name sea-seq -v /host/reports:/app/reports:rw sea-seq:latest
# docker run -d --name sea-seq -v /host/reports:/app/reports:rw -v /host/logs:/var/log/sea-seq:rw sea-seq:latest