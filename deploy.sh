#!/bin/bash

# 设置默认参数
IMAGE_NAME="text-to-voice-api"
CONTAINER_NAME="text-to-voice-container"
PORT="8000"
WORKERS=${WORKERS:-4}  # 默认4个工作进程

echo "🚀 Text-to-Voice API 部署工具"
echo "================================"

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ 错误: 未安装 Docker"
    echo "请先安装 Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# 检查镜像是否存在
image_exists() {
    docker images -q $IMAGE_NAME | grep -q .
}

# 询问用户是否需要构建镜像
build_image="n"
if image_exists; then
    echo "🔍 发现已存在的镜像: $IMAGE_NAME"
    read -p "❓ 是否重新构建镜像? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        build_image="y"
    fi
else
    echo "⚠️  未找到镜像: $IMAGE_NAME"
    build_image="y"
fi

# 构建镜像（如果需要）
if [[ $build_image == "y" ]]; then
    echo "📦 正在构建 Docker 镜像..."
    if docker build -t $IMAGE_NAME .; then
        echo "✅ Docker 镜像构建成功"
    else
        echo "❌ Docker 镜像构建失败"
        exit 1
    fi
else
    echo "⏭️  跳过镜像构建，使用现有镜像"
fi

# 停止并删除旧容器（如果存在）
echo "🛑 停止并删除旧容器..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# 运行新容器
echo "🏃 正在运行新容器..."
if docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:8000 \
    -e WORKERS=$WORKERS \
    $IMAGE_NAME; then
    echo "✅ 容器启动成功"
else
    echo "❌ 容器启动失败"
    exit 1
fi

echo ""
echo "🎉 部署完成！"
echo "🔗 API 地址: http://localhost:$PORT"
echo "📊 工作进程数: $WORKERS"
echo "🔧 调整进程数: export WORKERS=8 && ./$0"
echo "📋 查看日志: docker logs -f $CONTAINER_NAME"
echo "🏥 健康检查: curl http://localhost:$PORT/health"
