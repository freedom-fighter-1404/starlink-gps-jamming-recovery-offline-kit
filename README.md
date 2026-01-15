# Starlink Offline GPS Anti‑Jamming Kit (Iran)

[English](#english) | [فارسی](#فارسی)

## English

This repository is a **fully offline** kit to help Starlink users recover service when **GPS/GNSS jamming** prevents a terminal from getting a reliable fix.

It includes:
- Click‑to‑run launchers for **Windows / macOS / Linux**
- Bundled `grpcurl` binaries (no internet needed after you have the folder)
- A safe **Probe** mode to check whether your firmware exposes the required request field
- Bilingual documentation (English + فارسی)

### Security & verification (read this first)
Quick rule: **verify before you run**.

If you downloaded this from GitHub Releases:
1) Download the ZIP for your OS **and** the matching `.sha256` file.
2) Verify the ZIP’s SHA‑256 matches the `.sha256` value (see `docs/VERIFY.md`).
3) Extract the ZIP, then run the built‑in integrity check:
   - Windows: `verify_integrity.bat`
   - macOS/Linux: `./verify_integrity.sh`

This project uses **SHA‑256** checksums for verification and does **not** provide GPG signatures at this time.

### Important (read first)
- Use only on equipment you own/control, and follow local laws and Starlink terms.
- This kit addresses **GPS/GNSS jamming only**. If the Ku/Ka user link is jammed, performance may still be degraded.
- This kit only talks to the dish on your **local network** (`192.168.100.1`). It does not contact external servers.
- No one can “verify 100%” without hardware + real jamming conditions; this kit is validated against public references and is designed to fail safely.

### Quick start (no internet required)
1) Connect your device to **Starlink Wi‑Fi** (same local network as the dish).
2) Run ONE launcher:
   - Windows: double‑click `START_WINDOWS.bat`
   - macOS: double‑click `START_MAC.command`
   - Linux: run `./START_LINUX.sh`
3) Choose **Disable GPS**.
   - If it resets after a reboot, use **Daemon disable** (re-sends every 5 minutes).
   - Use **Status** to print current output.
   - If Disable GPS fails, run **Probe** and read `docs/OLDER_FIRMWARE.md`.

### What it does (verified against public tooling)
When supported by your Starlink firmware, it sends this local gRPC request:

`{"dish_inhibit_gps":{"inhibit_gps":true}}`

to:

`192.168.100.1:9200 SpaceX.API.Device.Device/Handle`

### Verify integrity (recommended in high-risk environments)
- Windows: run `verify_integrity.bat` (or `verify_integrity.ps1`)
- macOS/Linux: run `./verify_integrity.sh`
- Verification guide (releases + hashes): `docs/VERIFY.md`
- More: `docs/SECURITY.md` and `docs/AUDIT.md`


---

## فارسی

<div dir="rtl" align="right">

این مخزن یک کیت **کاملاً آفلاین** است برای زمانی که **پارازیت GPS/GNSS** باعث می‌شود دیش استارلینک نتواند موقعیت/زمان را درست تشخیص دهد و اتصال دچار مشکل شود.

این کیت شامل موارد زیر است:

- فایل‌های اجرایی “کلیک و اجرا” برای **Windows / macOS / Linux**
- باینری آماده‌ی `grpcurl` (بعد از داشتن پوشه، اینترنت لازم نیست)
- حالت **Probe** برای بررسی اینکه فریمور شما فیلد مورد نیاز را دارد یا نه
- مستندات دو زبانه (English + فارسی)

### امنیت و صحت‌سنجی (حتماً قبل از اجرا)
قاعده ساده: **قبل از اجرا، صحت‌سنجی کنید**.

اگر این کیت را از بخش Releases دریافت کرده‌اید:
1) فایل ZIP مخصوص سیستم‌عامل خود **و** فایل `.sha256` مربوط به همان ZIP را دانلود کنید.
2) هش SHA‑256 فایل ZIP را با مقدار داخل فایل `.sha256` مقایسه کنید (راهنما: `docs/VERIFY_FA.md`).
3) ZIP را Extract کنید و سپس صحت‌سنجی داخلی را اجرا کنید:
   - Windows: `verify_integrity.bat`
   - macOS/Linux: `./verify_integrity.sh`

این پروژه برای صحت‌سنجی از **SHA‑256** استفاده می‌کند و در حال حاضر امضای GPG ارائه نمی‌کند.

### نکات مهم (حتماً بخوانید)
- فقط روی تجهیزاتی که مالک/مسئول آن هستید استفاده کنید و قوانین محلی و شرایط سرویس استارلینک را رعایت کنید.
- این کیت فقط مشکل **پارازیت GPS/GNSS** را هدف می‌گیرد. اگر لینک Ku/Ka هم پارازیت شود، ممکن است باز هم افت کیفیت داشته باشید.
- این کیت فقط با دیش روی **شبکه محلی** شما صحبت می‌کند (`192.168.100.1`) و به هیچ سرور خارجی وصل نمی‌شود.
- بدون سخت‌افزار و شرایط واقعی پارازیت، هیچکس نمی‌تواند “۱۰۰٪ تضمین” بدهد؛ این کیت بر اساس منابع عمومی صحت‌سنجی شده و طوری طراحی شده که در صورت ناسازگاری، ایمن و شفاف خطا بدهد.

### شروع سریع (بدون نیاز به اینترنت)
1) به **Wi‑Fi استارلینک** وصل شوید (همان شبکه محلی دیش).
2) فقط یکی را اجرا کنید:
   - Windows: روی `START_WINDOWS.bat` دوبار کلیک کنید
   - macOS: روی `START_MAC.command` دوبار کلیک کنید
   - Linux: دستور `./START_LINUX.sh` را اجرا کنید
3) گزینه **Disable GPS** را انتخاب کنید.
   - اگر بعد از ریبوت برمی‌گردد، از **Daemon disable** استفاده کنید (هر ۵ دقیقه دوباره ارسال می‌کند).
   - برای دیدن خروجی وضعیت از **Status** استفاده کنید.
   - اگر خطا داد، **Probe** را اجرا کنید و `docs/OLDER_FIRMWARE_FA.md` را بخوانید.

### این کیت چه کاری می‌کند؟ (بر اساس ابزارهای عمومی)
در صورت پشتیبانی فریمور، این درخواست gRPC را به صورت محلی ارسال می‌کند:

`{"dish_inhibit_gps":{"inhibit_gps":true}}`

به آدرس:

`192.168.100.1:9200 SpaceX.API.Device.Device/Handle`

### صحت‌سنجی (در محیط‌های پرریسک توصیه می‌شود)
- Windows: `verify_integrity.bat` (یا `verify_integrity.ps1`) را اجرا کنید
- macOS/Linux: `./verify_integrity.sh` را اجرا کنید
- راهنمای صحت‌سنجی (Release و هش‌ها): `docs/VERIFY_FA.md`
- اطلاعات بیشتر: `docs/SECURITY_FA.md` و `docs/AUDIT.md

</div>
