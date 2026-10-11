# Standalone Dockerfile for ah-mcp
FROM golang:1.27-alpine@sha256:3b15ba438c60ab8fabe5fee3b11025c0049e358b31feff384648f11fc8e335f8 AS builder

WORKDIR /build

RUN apk add --no-cache git ca-certificates

COPY go.mod go.sum* ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o ah-mcp .

FROM alpine:3.24@sha256:d56c381f961d307a21b3ca004cf1e3910f106644aefb1f43e654c8a56c4fd395

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
