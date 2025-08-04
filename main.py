from fastapi import FastAPI, HTTPException, Response
from pydantic import BaseModel
import edge_tts
import tempfile
import asyncio
import os
import logging

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

class TTSRequest(BaseModel):
    text: str
    voice: str = "zh-CN-YunxiNeural"
    rate: str = "+0%"
    volume: str = "+0%"

@app.post("/textToVoice")
async def text_to_voice(request: TTSRequest):
    try:
        logger.info(f"Processing TTS request for text: {request.text[:50]}...")
        
        tts = edge_tts.Communicate(
            text=request.text,
            voice=request.voice,
            rate=request.rate,
            volume=request.volume
        )

        with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as temp_file:
            temp_filename = temp_file.name

        await tts.save(temp_filename)

        with open(temp_filename, "rb") as audio_file:
            audio_data = audio_file.read()

        os.remove(temp_filename)
        logger.info("TTS processing completed successfully")

        return Response(content=audio_data, media_type="audio/mpeg")

    except Exception as e:
        logger.error(f"Error in TTS processing: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
