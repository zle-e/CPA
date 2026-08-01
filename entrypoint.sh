#!/bin/sh

# 强制监听0.0.0.0，适配Koyeb反向代理与健康检查
sed -i "s/^\(\s*host:\).*/\1 \"0.0.0.0\"/" config.yaml

# 自动读取Koyeb注入的PORT环境变量，兜底8080
sed -i "s/^\(\s*port:\).*/\1 ${PORT:-8080}/" config.yaml

# 认证数据目录改到/data，适配持久化卷，避免家目录权限问题
sed -i "s|^\(\s*auth-dir:\).*|\1 \"/data\"|" config.yaml

# 启动服务
exec ./CLIProxyAPI --config config.yaml
