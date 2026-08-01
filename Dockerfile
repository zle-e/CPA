# 构建阶段：升级 Go 版本至 1.26，匹配项目要求
FROM golang:1.26-alpine AS builder
WORKDIR /build
RUN apk add --no-cache git
# 开启自动工具链，兼容版本波动
ENV GOTOOLCHAIN=auto
RUN git clone https://github.com/router-for-me/CLIProxyAPI.git .
# 静态编译，无系统依赖
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -o CLIProxyAPI .

# 运行阶段
FROM alpine:3.20
WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata
ENV TZ=Asia/Shanghai

# 创建非 root 用户与数据目录，适配 Koyeb 安全策略
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
