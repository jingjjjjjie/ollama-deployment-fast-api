# 1. 构建镜像（包括下载模型）
docker-compose build
  ↓
  - 构建 ollama 镜像（自动下载 gpt-oss:20b）
  - 构建 fastapi 镜像

# 2. 启动服务
docker-compose up -d
  ↓
  - 启动 ollama 容器（模型已经在镜像里）
  - 启动 fastapi 容器