from fastapi import FastAPI, HTTPException, Response
from pydantic import BaseModel, Field
from fastapi.middleware.cors import CORSMiddleware
import edge_tts
import tempfile
import asyncio
import os
import uuid
import logging

# =========================
# 配置日志
# =========================
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# =========================
# 初始化 FastAPI
# =========================
app = FastAPI(title="Edge-TTS Server", version="1.1")

# CORS 允许跨域请求
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 生产环境请限制具体域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# 请求模型
# =========================
class TTSRequest(BaseModel):
    text: str = Field(..., description="要合成的文本内容", min_length=1, max_length=2000)
    voice: str = Field(default="zh-CN-YunxiNeural", description="语音模型，如 vi-VN-HoaiMyNeural")
    rate: str = Field(default="+0%", description="语速调整，如 +10%、-10%")
    volume: str = Field(default="+0%", description="音量调整，如 +10%、-10%")


# =========================
# 主接口：文本转语音
# =========================
@app.post("/textToVoice")
async def text_to_voice(request: TTSRequest):
    try:
        logger.info(f"[TTS] Generating voice for: {request.text[:50]}... ({request.voice})")

        # 创建临时文件
        temp_filename = os.path.join(tempfile.gettempdir(), f"tts_{uuid.uuid4().hex}.mp3")

        # 异步生成语音
        communicate = edge_tts.Communicate(
            text=request.text,
            voice=request.voice,
            rate=request.rate,
            volume=request.volume
        )

        await communicate.save(temp_filename)

        # 读取音频内容
        with open(temp_filename, "rb") as f:
            audio_data = f.read()

        # 清理文件
        os.remove(temp_filename)

        logger.info("[TTS] Completed successfully")

        return Response(content=audio_data, media_type="audio/mpeg")

    except Exception as e:
        logger.exception("TTS generation failed")
        raise HTTPException(status_code=500, detail=str(e))


# =========================
# 获取支持的语音列表
# =========================
@app.get("/voices")
async def list_voices():
    """返回支持的语音模型列表"""
    try:
        voices = await edge_tts.list_voices()
        return {"count": len(voices), "voices": voices}
    except Exception as e:
        logger.error(f"Error fetching voices: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch voices")


# =========================
# 健康检测
# =========================
@app.get("/health")
async def health_check():
    return {"status": "healthy"}


# =========================
# 启动方式（开发时）
# =========================
# 启动命令：
# uvicorn main:app --reload --host 0.0.0.0 --port 8000
