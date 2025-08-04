# Text-to-Voice API

基于 FastAPI 和 Edge TTS 的高性能文本转语音服务，支持多进程并发处理。

## 🌟 特性

- **高性能**: 基于 FastAPI 和 Uvicorn，支持异步处理
- **高并发**: Gunicorn 多进程部署，充分利用多核 CPU
- **易部署**: Docker 化部署，一键启动
- **灵活配置**: 支持自定义语音、语速、音量
- **多语言**: 支持多种语言和语音风格

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone  https://github.com/shixiuhai/edge-tts-fast-api
cd text-to-voice-api
```

### 2. 赋予脚本执行权限

```bash
chmod +x deploy.sh
```

### 3. 部署服务

```bash
# 交互式部署（会询问是否构建镜像）
./deploy.sh

# 自定义配置部署
export WORKERS=8  # 设置工作进程数
export PORT=8080  # 设置端口
./deploy.sh
```

### 4. 验证服务

```bash
# 健康检查
curl http://localhost:8000/health

# 测试 TTS 功能
curl -X POST "http://localhost:8000/textToVoice" \
     -H "Content-Type: application/json" \
     -d '{"text":"你好，世界！","voice":"zh-CN-YunxiNeural","rate":"+10%","volume":"+5%"}' \
     --output output.mp3
```

## 📋 API 接口

### POST /textToVoice

将文本转换为语音

**请求参数:**

```json
{
  "text": "要转换的文本内容",
  "voice": "语音类型，默认: zh-CN-YunxiNeural",
  "rate": "语速，格式: +0% 或 -10%，默认: +0%",
  "volume": "音量，格式: +0% 或 +5%，默认: +0%"
}
```

**响应:**
- 成功: 返回 MP3 音频文件
- 失败: 返回 JSON 错误信息

**示例请求:**

```bash
curl -X POST "http://localhost:8000/textToVoice" \
     -H "Content-Type: application/json" \
     -d '{
       "text": "欢迎使用 Text-to-Voice API",
       "voice": "zh-CN-YunxiNeural",
       "rate": "+15%",
       "volume": "+10%"
     }' \
     --output welcome.mp3
```

### GET /health

服务健康检查

**响应:**
```json
{
  "status": "healthy"
}
```

## 🎭 支持的语音类型

### 中文语音
- `zh-CN-XiaoxiaoNeural` - 晓晓（女声）
- `zh-CN-YunxiNeural` - 云希（男声）
- `zh-CN-YunjianNeural` - 云健（男声）
- `zh-CN-XiaoyiNeural` - 晓伊（女声）
- `zh-CN-YunyangNeural` - 云扬（男声）

### 英文语音
- `en-US-JennyNeural` - Jenny（女声）
- `en-US-GuyNeural` - Guy（男声）
- `en-GB-SoniaNeural` - Sonia（女声）
- `en-GB-RyanNeural` - Ryan（男声）

### 其他语言
支持 70+ 种语言，完整列表请参考 [Edge TTS 文档](https://github.com/rany2/edge-tts)

## ⚙️ 配置选项

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `WORKERS` | 4 | Gunicorn 工作进程数 |
| `PORT` | 8000 | 服务端口 |

### 语速和音量格式

- **语速 (rate)**: `+0%`, `+10%`, `-5%`, `+20%` 等
- **音量 (volume)**: `+0%`, `+5%`, `-10%`, `+15%` 等

## 🐳 Docker 部署

### 手动构建和运行

```bash
# 构建镜像
docker build -t text-to-voice-api .

# 运行容器
docker run -d \
  --name text-to-voice-container \
  -p 8000:8000 \
  -e WORKERS=4 \
  text-to-voice-api
```

### 查看日志

```bash
# 实时查看日志
docker logs -f text-to-voice-container

# 查看最近日志
docker logs text-to-voice-container
```

### 停止和删除

```bash
# 停止容器
docker stop text-to-voice-container

# 删除容器
docker rm text-to-voice-container

# 删除镜像
docker rmi text-to-voice-api
```

## 📊 性能调优

### 工作进程数设置

建议根据 CPU 核心数设置工作进程数：

```bash
# 查看 CPU 核心数
nproc

# 设置工作进程数为 CPU 核心数
export WORKERS=$(nproc)
./deploy.sh
```

### 内存优化

对于内存受限的环境，可以减少工作进程数：

```bash
export WORKERS=2
./deploy.sh
```

## 🔧 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 查看端口占用
   lsof -i :8000
   
   # 更换端口
   export PORT=8080
   ./deploy.sh
   ```

2. **Docker 权限问题**
   ```bash
   # 将用户添加到 docker 组
   sudo usermod -aG docker $USER
   # 重新登录或执行
   newgrp docker
   ```

3. **查看详细错误信息**
   ```bash
   # 查看容器日志
   docker logs text-to-voice-container
   
   # 实时查看日志
   docker logs -f text-to-voice-container
   ```

### 服务监控

```bash
# 查看容器资源使用情况
docker stats text-to-voice-container

# 查看进程信息
docker exec -it text-to-voice-container ps aux
```

## 🛠️ 开发指南

### 本地开发

```bash
# 安装依赖
pip install -r requirements.txt

# 启动开发服务器
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 代码结构

```
text-to-voice-api/
├── main.py          # 主应用文件
├── Dockerfile       # Docker 配置文件
├── requirements.txt # Python 依赖
├── deploy.sh        # 部署脚本
└── README.md        # 说明文档
```

## 📈 性能基准测试

### 并发测试

```bash
# 安装测试工具
pip install apache2-utils

# 进行并发测试
ab -n 1000 -c 50 -p test.json -T "application/json" http://localhost:8000/textToVoice/
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目！

## 📄 许可证

MIT License

## 🙏 致谢

- [FastAPI](https://fastapi.tiangolo.com/) - 高性能 Python Web 框架
- [Edge TTS](https://github.com/rany2/edge-tts) - Microsoft Edge TTS Python 库
- [Gunicorn](https://gunicorn.org/) - Python WSGI HTTP Server

---

**注意**: 本服务依赖 Microsoft Edge TTS 在线服务，请确保网络连接正常。
