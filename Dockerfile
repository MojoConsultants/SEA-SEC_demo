# -----------------------------
# Stage 1: Build Go CLI (seaseq)
# -----------------------------
FROM golang:1.25.1 AS builder
WORKDIR /app

# Copy go.mod first (for dependency caching)
COPY go.mod ./
RUN [ -f go.sum ] || echo "" > go.sum
COPY go.sum ./

# Copy the rest of the project
COPY . .

# Download dependencies
RUN go mod tidy && go mod download

# Build CLI binary
# Try cmd/sea-qa first; if missing, fallback to repo root
RUN if [ -d "./cmd/sea-qa" ]; then \
      go build -o /bin/seaseq ./cmd/sea-qa ; \
    else \
      go build -o /bin/seaseq . ; \
    fi

# Optional: strip binary to reduce size
RUN strip /bin/seaseq || true

# -----------------------------
# Stage 2: Python API service
# -----------------------------
FROM python:3.11-slim AS api
WORKDIR /app

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends gcc && rm -rf /var/lib/apt/lists/*

# Install Python requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY . .

# Expose FastAPI port
EXPOSE 8000

# -----------------------------
# Stage 3: Final image selector
# -----------------------------
FROM api AS final

# Copy seaseq CLI binary from builder
COPY --from=builder /bin/seaseq /usr/local/bin/seaseq

# Default entrypoint → FastAPI service
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]

# To run CLI instead, override entrypoint in docker run:
# docker run --entrypoint seaseq <image> <args>
# Example: docker run --entrypoint seaseq <image> version
echo