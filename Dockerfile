# -----------------------------
# Stage 1: Build the SEA-SEQ CLI with Go
# -----------------------------
FROM golang:1.22 AS builder
WORKDIR /app

# Copy dependency manifests first
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source
COPY . .

# Build CLI
RUN go build -o seaseq ./cmd/sea-qa


# -----------------------------
# Stage 2: Runtime with Python + seaseq
# -----------------------------
FROM python:3.11-slim

# Install OS deps for Python (adjust if needed)
RUN apt-get update && apt-get install -y gcc libpq-dev && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy seaseq binary from builder
COPY --from=builder /app/seaseq /app/seaseq

# Copy project files (YAMLs, Python scripts, etc.)
COPY . .

# Install Python requirements
RUN pip install --no-cache-dir -r requirements.txt

# Default command: show help
CMD ["./seaseq", "--help"]
# You can override this in `docker run` to execute specific commands
# Example: docker run <image> ./seaseq run --help       
 