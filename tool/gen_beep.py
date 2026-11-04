# 生成节拍器短促"嘀嗒"声 wav（1kHz，65ms，指数衰减），44100Hz 16bit mono。
import math, struct, wave, os

SR = 44100
DUR = 0.065
FREQ = 1000.0
N = int(SR * DUR)
frames = bytearray()
for i in range(N):
    t = i / SR
    env = math.exp(-3.0 * i / N)  # 快速衰减，避免爆音
    val = int(0.6 * env * math.sin(2 * math.pi * FREQ * t) * 32767)
    frames += struct.pack('<h', val)

out = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio', 'metronome.wav')
os.makedirs(os.path.dirname(out), exist_ok=True)
with wave.open(out, 'wb') as w:
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(bytes(frames))
print('wrote', os.path.normpath(out), len(frames) // 2, 'samples')
