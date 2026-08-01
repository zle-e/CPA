FROM alpine:3.20
WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata curl
ENV TZ=Asia/Shanghai

# 下载官方预编译二进制，避开编译坑
RUN curl -L -o CLIProxyAPI https://github.com/router-for-me/CLIProxyAPI/releases/latest/download/CLIProxyAPI_linux_amd64 \
    && chmod +x CLIProxyAPI

# 直接拷贝配置文件，不做动态修改
COPY config.yaml ./

EXPOSE 8080
# 直接启动，指定配置文件
CMD ["./CLIProxyAPI", "--config", "config.yaml"]
