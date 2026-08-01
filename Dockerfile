# 构建阶段：拉取官方源码编译
FROM golang:1.23-alpine AS builder
WORKDIR /build
RUN apk add --no-cache git
RUN git clone https://github.com/router-for-me/CLIProxyAPI.git .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -o CLIProxyAPI .

# 运行阶段
FROM alpine:3.20
WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata
ENV TZ=Asia/Shanghai

# 创建运行用户和数据目录，适配Koyeb安全策略
RUN addgroup -S app && adduser -S app -G app \
    && mkdir -p /app /data \
    && chown -R app:app /app /data

# 拷贝二进制、配置、启动脚本
COPY --from=builder /build/CLIProxyAPI ./
COPY config.yaml ./
COPY entrypoint.sh ./
RUN chmod +x CLIProxyAPI entrypoint.sh

USER app
EXPOSE 8080
ENTRYPOINT ["./entrypoint.sh"]
