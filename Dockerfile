# 1. 自动拉取源码并构建后端 (使用最新的 1.26 版本)
FROM golang:1.26-alpine AS builder
RUN apk add --no-cache git
RUN git clone https://github.com/router-for-me/CLIProxyAPI.git /app
WORKDIR /app
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o ./CLIProxyAPI ./cmd/server/

# 2. 运行阶段
FROM alpine:latest
RUN apk add --no-cache tzdata
WORKDIR /app

# 拷贝编译好的程序和默认配置文件
COPY --from=builder /app/CLIProxyAPI .
COPY --from=builder /app/config.example.yaml ./config.example.yaml

# 尝试拷贝你自己创建的 config.yaml
COPY config.yam[l] ./

EXPOSE 7860

# 3. 启动脚本：智能判断配置 + 挂载持久化目录
RUN echo '#!/bin/sh' > start.sh && \
    # 强制将程序的默认数据生成目录软链接到持久化硬盘 /data
    echo 'rm -rf /root/.cli-proxy-api && ln -s /data /root/.cli-proxy-api' >> start.sh && \
    # 如果有 logs 文件夹需求，也挂载过去
    echo 'rm -rf /app/logs && ln -s /data /app/logs' >> start.sh && \
    echo 'if [ -f "config.yaml" ]; then' >> start.sh && \
    echo '  echo "检测到自定义 config.yaml，正在使用..."' >> start.sh && \
    # 强制把用户自己写的配置文件里的端口改成 7860，防止填错导致跑不起来
    echo '  sed -i "s/port: .*/port: 7860/g" config.yaml' >> start.sh && \
    echo '  ./CLIProxyAPI -config config.yaml' >> start.sh && \
    echo 'else' >> start.sh && \
    echo '  echo "未检测到自定义配置，使用默认配置..."' >> start.sh && \
    echo '  sed -i "s/port: .*/port: 7860/g" config.example.yaml' >> start.sh && \
    echo '  ./CLIProxyAPI -config config.example.yaml' >> start.sh && \
    echo 'fi' >> start.sh && \
    chmod +x start.sh

CMD ["./start.sh"]
