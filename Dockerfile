FROM alpine:3.20
WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata curl
ENV TZ=Asia/Shanghai

# 创建运行用户与数据目录
RUN addgroup -S app && adduser -S app -G app \
    && mkdir -p /app /data \
    && chown -R app:app /app /data

# 下载最新版官方预编译二进制（amd64 架构）
RUN curl -L -o CLIProxyAPI https://github.com/router-for-me/CLIProxyAPI/releases/latest/download/CLIProxyAPI_linux_amd64 \
    && chmod +x CLIProxyAPI

COPY config.yaml ./
COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

USER app
EXPOSE 8080
ENTRYPOINT ["./entrypoint.sh"]
