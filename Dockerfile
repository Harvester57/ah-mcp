# Standalone Dockerfile for ah-mcp
FROM golang:1.27-alpine@sha256:f92b6ef800e499660581efdabdf25d9d817a9d124eaf900924f0504e7e27e12d AS builder

WORKDIR /build

RUN apk add --no-cache git ca-certificates

COPY go.mod go.sum* ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o ah-mcp .

FROM alpine:3.24@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

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
