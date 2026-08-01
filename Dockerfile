FROM alpine:3.20
WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata curl

# 创建数据目录并开放权限，避免启动时报错
RUN mkdir -p /app/data && chmod 777 /app/data

# 下载官方预编译二进制
RUN curl -L -o cli-proxy-api https://github.com/router-for-me/CLIProxyAPI/releases/latest/download/CLIProxyAPI_linux_amd64 \
    && chmod +x cli-proxy-api

COPY config.yaml ./

EXPOSE 8080
CMD ["./cli-proxy-api", "--config", "config.yaml"]
