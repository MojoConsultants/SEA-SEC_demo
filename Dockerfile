# -----------------------------
# Stage 1: Build the Go binary
# -----------------------------
FROM golang:1.22 AS builder
WORKDIR /app

# Copy go.mod first (required)
COPY go.mod ./
# Copy go.sum only if present
# (avoids error when go.sum hasn't been generated yet)
RUN test -f go.sum || touch go.sum
COPY go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build CLI
RUN go build -o seaseq ./cmd/sea-qa

# -----------------------------
# Stage 2: Runtime container
# -----------------------------
FROM python:3.11-slim AS runtime
WORKDIR /app

# Install system dependencies (adjust as needed)
RUN apt-get update \
 && apt-get install -y gcc libpq-dev \
 && rm -rf /var/lib/apt/lists/*

# Copy binary and app code from builder
COPY --from=builder /app/seaseq /usr/local/bin/seaseq
COPY . .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
