#!/bin/bash

# 设置默认参数
IMAGE_NAME="text-to-voice-api"
CONTAINER_NAME="text-to-voice-container"
PORT="8000"
WORKERS=${WORKERS:-4}  # 默认4个工作进程

echo "🚀 开始部署 Text-to-Voice API..."

# 构建 Docker 镜像
echo "📦 构建 Docker 镜像..."
docker build -t $IMAGE_NAME .

# 停止并删除旧容器（如果存在）
echo "🛑 停止并删除旧容器..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# 运行新容器（支持多进程）
echo "🏃 运行新容器，使用 $WORKERS 个工作进程..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:8000 \
    -e WORKERS=$WORKERS \
    $IMAGE_NAME

echo "✅ 部署完成！API 已运行在 http://localhost:$PORT"
echo "📊 当前工作进程数: $WORKERS"
echo "🔧 可通过设置 WORKERS 环境变量调整进程数，例如: export WORKERS=8"
echo "📋 查看日志: docker logs -f $CONTAINER_NAME"
