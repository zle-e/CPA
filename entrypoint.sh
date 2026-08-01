#!/bin/sh
# 强制监听 0.0.0.0，兼容带引号的 YAML 格式
sed -i "s/^\(\s*host:\).*/\1 \"0.0.0.0\"/" config.yaml
# 自动读取 Koyeb 注入的 PORT，兜底 8080
sed -i "s/^\(\s*port:\).*/\1 ${PORT:-8080}/" config.yaml
# 认证数据改到 /data，适配持久化卷与非 root 权限
sed -i "s|^\(\s*auth-dir:\).*|\1 \"/data\"|" config.yaml

# 官方启动参数为双横杠 --config
exec ./CLIProxyAPI --config config.yaml
