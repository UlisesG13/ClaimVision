import requests, json, time

BASE = 'https://api.actividades.icu'
AI_BASE = 'https://ia.actividades.icu'
results = []

def test(method, path, desc, base_url=None, **kwargs):
    url = (base_url or BASE) + path
    try:
        r = requests.request(method, url, timeout=30, **kwargs)
        body = r.json() if r.text.strip() and r.headers.get('content-type','').startswith('application/json') else r.text[:300]
    except Exception as e:
        r = None
        body = str(e)[:200]
    status = r.status_code if r else 0
    ok = "OK" if 200 <= status < 400 else ("ERR" if status >= 500 else "WARN")
    results.append({"endpoint": path, "method": method.upper(), "status": status, "body": body, "desc": desc, "base": base_url or BASE})
    detail = str(body)[:150] if isinstance(body, str) else json.dumps(body, ensure_ascii=False)[:150]
    print(f"  [{ok:4s}] {method.upper():6s} {path:55s} {status:4d} | {detail}")
    return r

# ─── Auth ───
print("=== AUTH ===\n")
ts = int(time.time())
r = requests.post(BASE + '/api/v1/auth/register', json={'nombre': 'Tester','email': f'tester_{ts}@example.com','password': 'Test1234!'}, timeout=15)
if r.status_code not in (200, 201):
    r = requests.post(BASE + '/api/v1/auth/login', json={'email': f'tester_{ts}@example.com','password': 'Test1234!'}, timeout=15)
token = r.json().get('token', '')
h = {'Authorization': f'Bearer {token}'}
print(f"  Token OK\n")

# ─── Test IA OCR endpoints ───
print("=== IA OCR ===\n")

# Valid PDF (minimal)
pdf = b'%PDF-1.4\n1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] >>\nendobj\nxref\n0 4\n0000000000 65535 f \n0000000009 00000 n \n0000000058 00000 n \n0000000115 00000 n \ntrailer\n<< /Size 4 /Root 1 0 R >>\nstartxref\n190\n%%EOF'

# Valid JPEG (1x1 pixel)
jpg = b'\xff\xd8\xff\xe0\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00\xff\xdb\x00C\x00\x08\x06\x06\x07\x06\x05\x08\x07\x07\x07\t\t\x08\n\x0c\x14\r\x0c\x0b\x0b\x0c\x19\x12\x13\x0f\x14\x1d\x1a\x1f\x1e\x1d\x1a\x1c\x1c $.\'",#\x1c\x1c(7),01444\x1f\'9=82<.342\xff\xc0\x00\x0b\x08\x00\x01\x00\x01\x01\x01\x11\x00\xff\xc4\x00\x1f\x00\x00\x01\x05\x01\x01\x01\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x01\x02\x03\x04\x05\x06\x07\x08\t\n\x0b\xff\xc4\x00\xb5\x10\x00\x02\x01\x03\x03\x02\x04\x03\x05\x05\x04\x04\x00\x00\x00\x00\x00\x00\x01\x02\x03\x11\x04\x12!1A\x06\x13Qa\x07"q\x142\x81\x91\xa1\x08#B\xb1\xc1\x15R\xd1\xf0$3br\x82\t\n\x16\x17\x18\x19\x1a%&\'()*456789:CDEFGHIJSTUVWXYZcdefghijstuvwxyz\x83\x84\x85\x86\x87\x88\x89\x8a\x92\x93\x94\x95\x96\x97\x98\x99\x9a\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xff\xc4\x00\x1f\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x00\x00\x00\x00\x00\x00\x01\x02\x03\x04\x05\x06\x07\x08\t\n\x0b\xff\xc4\x00\xb5\x11\x00\x02\x01\x02\x04\x04\x03\x04\x07\x05\x04\x04\x01\x02\x77\x00\x01\x02\x03\x11\x04\x05!1\x06\x12AQ\x07aq\x13"2\x08\x14B\x91\xa1\xb1\xc1\t#3R\x15\x16\x17\x18\x19\x1a$%&\'()*456789:CDEFGHIJSTUVWXYZcdefghijstuvwxyz\x82\x83\x84\x85\x86\x87\x88\x89\x8a\x92\x93\x94\x95\x96\x97\x98\x99\x9a\xa2\xa3\xa4\xa5\xa6\xa7\xa8\xa9\xaa\xb2\xb3\xb4\xb5\xb6\xb7\xb8\xb9\xba\xc2\xc3\xc4\xc5\xc6\xc7\xc8\xc9\xca\xd2\xd3\xd4\xd5\xd6\xd7\xd8\xd9\xda\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xff\xda\x00\x08\x01\x01\x00\x00?\x00F$\x01\x00\xff\xd9'

# NLP analizar
r = requests.post(AI_BASE + '/api/v1/nlp/analizar', headers=h, json={'texto': 'Golpe en la puerta delantera izquierda con abolladura'}, timeout=30)
print(f"  {('OK' if 200<=r.status_code<400 else 'ERR'):4s} POST   /api/v1/nlp/analizar{' ':<44} {r.status_code:4d} | {r.text[:150]}")

# NLP transcribir
r = requests.post(AI_BASE + '/api/v1/nlp/transcribir', headers=h, files={'file': ('audio.mp3', b'', 'audio/mpeg')}, timeout=30)
print(f"  {('OK' if 200<=r.status_code<400 else 'ERR'):4s} POST   /api/v1/nlp/transcribir{' ':<43} {r.status_code:4d} | {r.text[:150]}")
job_id = r.json().get('job_id','') if r.status_code == 200 else ''

# NLP transcribir status
if job_id:
    time.sleep(2)
    r = requests.get(AI_BASE + f'/api/v1/nlp/transcribir/status/{job_id}', headers=h, timeout=30)
    print(f"  {('OK' if 200<=r.status_code<400 else 'ERR'):4s} GET    /api/v1/nlp/transcribir/status/{{{job_id[:8]}...}}{' ':<30} {r.status_code:4d} | {r.text[:150]}")

# OCR extract (base)
r = requests.post(AI_BASE + '/api/v1/ocr', headers=h, files={'file': ('test.pdf', pdf, 'application/pdf')}, timeout=30)
print(f"  {('OK' if 200<=r.status_code<400 else 'ERR'):4s} POST   /api/v1/ocr{' ':<50} {r.status_code:4d} | {r.text[:150]}")

# OCR extract-ine
r = requests.post(AI_BASE + '/api/v1/ocr/extract-ine', headers=h, files={'file': ('ine.pdf', pdf, 'application/pdf')}, timeout=30)
print(f"  {('OK' if 200<=r.status_code<400 else 'ERR'):4s} POST   /api/v1/ocr/extract-ine{' ':<41} {r.status_code:4d} | {r.text[:150]}")

# OCR extract-poliza
r = requests.post(AI_BASE + '/api/v1/ocr/extract-poliza', headers=h, files={'file': ('poliza.pdf', pdf, 'application/pdf')}, timeout=30)
print(f"  {('OK' if 200<=r.status_code<400 else 'ERR'):4s} POST   /api/v1/ocr/extract-poliza{' ':<39} {r.status_code:4d} | {r.text[:150]}")

# OCR extract-and-validate
r = requests.post(AI_BASE + '/api/v1/ocr/extract-and-validate', headers=h, files={'ine': ('ine.pdf', pdf, 'application/pdf'), 'poliza': ('poliza.pdf', pdf, 'application/pdf')}, timeout=30)
print(f"  {('OK' if 200<=r.status_code<400 else 'ERR'):4s} POST   /api/v1/ocr/extract-and-validate{' ':<29} {r.status_code:4d} | {r.text[:150]}")

# Predict
r = requests.post(AI_BASE + '/api/v1/predict', headers=h, files={'file': ('damage.jpg', jpg, 'image/jpeg')}, timeout=30)
print(f"  {('OK' if 200<=r.status_code<400 else 'ERR'):4s} POST   /api/v1/predict{' ':<48} {r.status_code:4d} | {r.text[:150]}")

# ─── Backend endpoint ───
print("\n=== BACKEND OCR ===\n")
r = requests.post(BASE + '/api/v1/cliente/onboarding/ocr', headers=h, data={'cedula': '12345678', 'poliza': 'POL-001'}, timeout=30)
print(f"  {('OK' if 200<=r.status_code<400 else 'ERR'):4s} POST   /api/v1/cliente/onboarding/ocr{' ':<25} {r.status_code:4d} | {r.text[:150]}")

print(f"\n{'='*60}")
print("RESUMEN IA + OCR")
print(f"{'='*60}")
