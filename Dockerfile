FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY . .

# Build statically linked binary
RUN CGO_ENABLED=0 GOOS=linux go install -a -ldflags '-extldflags "-s -w -static"' .

# ---------- Runtime Stage ----------
FROM scratch

# Copy binary from builder
COPY --from=builder /go/bin/deadman /usr/local/bin/deadman

EXPOSE 9095

ENTRYPOINT ["/usr/local/bin/deadman"]