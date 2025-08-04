#!/bin/bash

# 构建 Docker 镜像
docker build -t text-to-voice-api .

# 停止并删除旧容器（如果存在）
docker stop text-to-voice-container 2>/dev/null || true
docker rm text-to-voice-container 2>/dev/null || true

# 运行新容器
docker run -d --name text-to-voice-container -p 8000:8000 text-to-voice-api

echo "✅ API 已部署并运行在 http://localhost:8000"
