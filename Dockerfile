# Standalone Dockerfile for ah-mcp
FROM golang:1.27-alpine@sha256:eb61c3873c97416fff0116553fff65d67a3549f72e11d9758849a689cdd8b523 AS builder

WORKDIR /build

RUN apk add --no-cache git ca-certificates

COPY go.mod go.sum* ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o ah-mcp .

FROM alpine:3.24@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf

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
