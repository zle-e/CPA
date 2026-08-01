# 构建阶段：使用最新 Go 环境，自动适配版本要求
FROM golang:alpine AS builder
WORKDIR /build
RUN apk add --no-cache git
ENV GOTOOLCHAIN=auto

# 拉取官方源码
RUN git clone https://github.com/router-for-me/CLIProxyAPI.git .

# 自动查找 main.go 入口并编译
RUN find /build -name "main.go" -print0 | xargs -0 dirname | head -1 | xargs -I {} go build -trimpath -o /build/CLIProxyAPI {}

# 运行阶段
FROM alpine:3.20
WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata

# 创建数据目录并开放权限，避免启动报错
RUN mkdir -p /app/data && chmod 777 /app/data

# 拷贝编译好的二进制文件
COPY --from=builder /build/CLIProxyAPI ./
RUN chmod +x CLIProxyAPI

# 拷贝配置文件
COPY config.yaml ./

EXPOSE 8000
CMD ["./CLIProxyAPI", "--config", "config.yaml"]
