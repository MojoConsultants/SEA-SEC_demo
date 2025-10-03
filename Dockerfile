# ---------- Stage 1: Build ----------
FROM golang:1.22 AS builder

WORKDIR /src

# Copy go.mod only (since go.sum is missing)
COPY go.mod ./
RUN go mod download

# Copy everything else
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o seaqa ./cmd/sea-qa

# ---------- Stage 2: Runtime ----------
FROM alpine:3.20

WORKDIR /app
RUN apk add --no-cache ca-certificates

COPY --from=builder /src/seaqa /usr/local/bin/seaqa
COPY ./tests ./tests

# Pre-create reports directory
RUN mkdir -p /app/reports

ENTRYPOINT ["seaqa"]

CMD ["--help"]
EXPOSE 8080

