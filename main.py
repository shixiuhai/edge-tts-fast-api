from fastapi import FastAPI, HTTPException, Response
from pydantic import BaseModel
import edge_tts
import tempfile
import asyncio
import os

app = FastAPI()

class TTSRequest(BaseModel):
    text: str
    voice: str = "zh-CN-YunxiNeural"
    rate: str = "+0%"
    volume: str = "+0%"

@app.post("/textToVoice")
async def text_to_voice(request: TTSRequest):
    try:
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

        return Response(content=audio_data, media_type="audio/mpeg")

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
