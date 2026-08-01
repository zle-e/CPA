# 构建阶段
FROM golang:1.26-alpine AS builder
WORKDIR /build
RUN apk add --no-cache git
ENV GOTOOLCHAIN=auto

# 克隆官方源码
RUN git clone https://github.com/router-for-me/CLIProxyAPI.git .

# 编译 cmd 目录下的主程序，静态编译无系统依赖
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -o CLIProxyAPI ./cmd/

# 运行阶段
FROM alpine:3.20
WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata
ENV TZ=Asia/Shanghai

# 创建非 root 用户与数据目录，适配 Koyeb 安全策略
RUN addgroup -S app && adduser -S app -G app \
    && mkdir -p /app /data \
    && chown -R app:app /app /data

# 拷贝二进制、配置文件、启动脚本
COPY --from=builder /build/CLIProxyAPI ./
COPY config.yaml ./
COPY entrypoint.sh ./
RUN chmod +x CLIProxyAPI entrypoint.sh

USER app
EXPOSE 8080
ENTRYPOINT ["./entrypoint.sh"]
