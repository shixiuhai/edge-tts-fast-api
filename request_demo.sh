curl -X POST "http://localhost:8000/textToVoice" \
     -H "Content-Type: application/json" \
     -d '{"text":"你好，世界！","voice":"zh-CN-YunxiNeural","rate":"+10%","volume":"+5%"}' \
     --output output.mp3
