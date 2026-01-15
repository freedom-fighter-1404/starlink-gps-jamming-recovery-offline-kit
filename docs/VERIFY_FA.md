# صحت‌سنجی این کیت آفلاین (هش و یکپارچگی)

این کیت برای اشتراک‌گذاری آفلاین (USB، AirDrop، انتقال فایل محلی) طراحی شده است. در محیط‌های پرریسک، تا زمانی که صحت‌سنجی نکرده‌اید، فایل‌ها را قابل اعتماد فرض نکنید.

## ۱) بررسی هش فایل ZIP انتشار (پیشنهادی)
وقتی یک نسخه (Release) را دانلود می‌کنید، معمولاً این دو فایل را دارید:
- `…<platform>.zip`
- `…<platform>.zip.sha256`

هش SHA‑256 فایل ZIP را روی دستگاه خود حساب کنید و با مقدار داخل فایل `.sha256` مقایسه کنید:

**Windows (PowerShell):**
```powershell
Get-FileHash .\\your-file.zip -Algorithm SHA256
```

**Windows (Command Prompt):**
```bat
certutil -hashfile your-file.zip SHA256
```

**macOS:**
```bash
shasum -a 256 your-file.zip
```

**Linux:**
```bash
sha256sum your-file.zip
```

اگر هش مطابقت نداشت، کیت را اجرا نکنید.

## ۱-ب) بررسی امضای فایل ZIP انتشار (اختیاری، قوی‌تر از هش)
بعضی از انتشارها ممکن است علاوه بر هش، یک فایل **امضای OpenSSH** هم داشته باشند:
- `…<platform>.zip.sshsig`

برای بررسی امضا، این موارد لازم است:
- فایل ZIP
- فایل `.sshsig` مربوط به همان ZIP
- فایل‌های کلید عمومی (`release_keys/allowed_signers`)

اول، اثر انگشت (Fingerprint) کلید عمومی را از مسیر مستقل تأیید کنید:
- `release_keys/FINGERPRINT.txt`

سپس بررسی کنید:
```bash
ssh-keygen -Y verify \
  -f release_keys/allowed_signers \
  -I starlink-gps-jamming-recovery-offline-kit \
  -n starlink-gps-jamming-recovery-offline-kit-release \
  -s your-file.zip.sshsig < your-file.zip
```

## ۲) صحت‌سنجی پوشه بعد از Extract (صحت‌سنجی داخلی)
بعد از Extract کردن ZIP، محتویات پوشه را بررسی کنید:
- Windows: روی `verify_integrity.bat` دوبار کلیک کنید (یا `verify_integrity.ps1` را اجرا کنید)
- macOS/Linux: دستور `./verify_integrity.sh` را اجرا کنید

اگر پیام `OK: Integrity checks passed.` نمایش داده شد، یعنی:
- فایل‌های اجرایی و اسکریپت‌ها با `CHECKSUMS.sha256` مطابقت دارند
- باینری‌های `grpcurl` با `checksums/BUNDLED_FILES_SHA256.txt` مطابقت دارند

## شفاف‌سازی کامل: چه چیزی ارائه می‌شود؟
- این پروژه فایل‌های **SHA‑256** را ارائه می‌کند:
  - `…<platform>.zip.sha256` (هش ZIP انتشار)
  - `CHECKSUMS.sha256` (برای فایل‌های اسکریپت/مستندات بعد از Extract)
  - `checksums/BUNDLED_FILES_SHA256.txt` (برای باینری‌های داخل کیت)
- بعضی از انتشارها ممکن است امضای **OpenSSH** (`.sshsig`) هم داشته باشند (بخش بالا).
- در حال حاضر، این پروژه امضای PGP/GPG ارائه نمی‌کند.
- این صحت‌سنجی آفلاین است و به اینترنت وصل نمی‌شود.

## جزء داخل کیت: grpcurl
- نسخه: `v1.9.3`
- مجوز: `third_party/grpcurl/LICENSE`
- چک‌سام: `checksums/grpcurl_1.9.3_checksums.txt`
