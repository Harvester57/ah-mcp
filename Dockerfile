# Standalone Dockerfile for ah-mcp
FROM golang:1.27-alpine@sha256:b8c9b82affbbb82a020bbcf998dad2ba9516944ac7e883524642a481a9505e9c AS builder

WORKDIR /build

RUN apk add --no-cache git ca-certificates

COPY go.mod go.sum* ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o ah-mcp .

FROM alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

WORKDIR /app

RUN apk add --no-cache ca-certificates tzdata wget curl

COPY --from=builder /build/ah-mcp /app/ah-mcp

ENV AH_MCP_PORT=3001 \
    AH_CALLBACK_PORT=9876 \
    AH_CALLBACK_HOST=http://localhost:9876 \
    AH_TOKENS_PATH=/tokens/tokens.json \
    AH_REMOTE=true

VOLUME ["/tokens"]

EXPOSE 3001 9876

ENTRYPOINT ["/app/ah-mcp"]
CMD ["--transport", "sse", "--remote"]
