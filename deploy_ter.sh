#!/bin/bash

# 命令行参数版本
IMAGE_NAME="text-to-voice-api"
CONTAINER_NAME="text-to-voice-container"
PORT="8000"
WORKERS=${WORKERS:-4}
BUILD_IMAGE=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--build)
            BUILD_IMAGE=true
            shift
            ;;
        -w|--workers)
            WORKERS="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -h|--help)
            echo "用法: $0 [选项]"
            echo "选项:"
            echo "  -b, --build     强制构建镜像"
            echo "  -w, --workers   设置工作进程数 (默认: 4)"
            echo "  -p, --port      设置端口 (默认: 8000)"
            echo "  -h, --help      显示帮助信息"
            exit 0
            ;;
        *)
            echo "未知选项: $1"
            echo "使用 $0 --help 查看帮助"
            exit 1
            ;;
    esac
done

echo "🚀 Text-to-Voice API 部署工具"

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "❌ 错误: 未安装 Docker"
    exit 1
fi

# 构建镜像（如果需要）
if [[ $BUILD_IMAGE == true ]] || ! docker images -q $IMAGE_NAME | grep -q .; then
    echo "📦 构建 Docker 镜像..."
    docker build -t $IMAGE_NAME . || exit 1
    echo "✅ 镜像构建完成"
else
    echo "⏭️  使用现有镜像"
fi

# 停止并删除旧容器
echo "🛑 清理旧容器..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# 运行新容器
echo "🏃 启动容器 (工作进程: $WORKERS, 端口: $PORT)..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:8000 \
    -e WORKERS=$WORKERS \
    $IMAGE_NAME || exit 1

echo "🎉 部署完成！API 运行在 http://localhost:$PORT"
