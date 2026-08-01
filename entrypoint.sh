#!/bin/sh

# 1. 强制监听0.0.0.0，允许平台反向代理与健康检查访问
sed -i "s/^\(\s*host:\).*/\1 0.0.0.0/g" config.yaml

# 2. 自动读取Koyeb注入的PORT环境变量，默认兜底为8080
sed -i "s/^\(\s*port:\).*/\1 ${PORT:-8080}/g" config.yaml

# 3. 数据存储目录统一到/data，适配平台持久化卷挂载
sed -i "s|^\(\s*data_path:\).*|\1 /data|g" config.yaml

# 4. 启动服务（参数根据项目实际调整，注意单/双横杠匹配）
exec ./CLIProxyAPI -config config.yaml
