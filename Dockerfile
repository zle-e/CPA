# 第一阶段：构建阶段
FROM golang:1.23-alpine AS builder
WORKDIR /build

RUN apk add --no-cache git
COPY go.mod go.sum ./
RUN go mod download
COPY . .

# 静态编译，禁用CGO，兼容alpine运行环境
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -o CLIProxyAPI ./cmd/server/

# 第二阶段：运行阶段
FROM alpine:3.20
WORKDIR /app

# 安装基础依赖：CA证书（支持HTTPS）、时区数据
RUN apk add --no-cache ca-certificates tzdata
ENV TZ=Asia/Shanghai

# 创建非root用户，适配Koyeb安全运行策略，避免权限报错
RUN addgroup -S app && adduser -S app -G app

# 创建工作目录与持久化数据目录，分配权限
RUN mkdir -p /app /data && chown -R app:app /app /data

# 拷贝二进制、配置文件、启动脚本
COPY --from=builder /build/CLIProxyAPI ./
COPY config.yaml ./
COPY entrypoint.sh ./

RUN chmod +x entrypoint.sh
USER app

EXPOSE 8080
ENTRYPOINT ["./entrypoint.sh"]
