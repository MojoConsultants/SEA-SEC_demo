# -----------------------------
# Stage 1: Build Go CLI (seaseq)
# -----------------------------
FROM golang:1.25.1 AS builder
WORKDIR /app

# Copy only go.mod first
COPY go.mod ./
# Create empty go.sum if missing
RUN [ -f go.sum ] || echo "" > go.sum

# Copy rest of project (this will include go.sum if it exists locally)
COPY . .

# Download dependencies safely (works even if go.sum was empty)
RUN go mod tidy && go mod download

# Build CLI binary
RUN go build -o /bin/seaseq ./cmd/sea-qa

# -----------------------------
# Stage 2: Python API service
# -----------------------------
FROM python:3.11-slim AS api
WORKDIR /app

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends gcc && rm -rf /var/lib/apt/lists/*

# Copy Python requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app source
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
