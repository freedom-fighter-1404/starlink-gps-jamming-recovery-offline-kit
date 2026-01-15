# Starlink Offline GPS Anti‑Jamming Kit (Iran)

![Starlink Offline GPS Anti‑Jamming Kit](docs/media/hero.jpg)

[English](#english) | [فارسی](#فارسی)

## English

This repository is a **fully offline** kit to help Starlink users recover service when **GPS/GNSS jamming** prevents a terminal from getting a reliable fix.

It includes:
- Click‑to‑run launchers for **Windows / macOS / Linux**
- Bundled `grpcurl` binaries (no internet needed after you have the folder)
- A safe **Probe** mode to check whether your firmware exposes the required request field
- Offline gRPC schema included (works even if reflection is disabled)
- Bilingual documentation (English + فارسی)

### Download (GitHub Releases)
Get this kit from the official Releases page:

`https://github.com/freedom-fighter-1404/starlink-gps-jamming-recovery-offline-kit/releases`

Choose **ONE** ZIP:
- **Windows:** `starlink-gps-jamming-recovery-offline-kit_v1.0.4_windows.zip`
- **macOS (Intel + Apple Silicon):** `starlink-gps-jamming-recovery-offline-kit_v1.0.4_macos.zip`
- **Linux (x86_64 + arm64):** `starlink-gps-jamming-recovery-offline-kit_v1.0.4_linux.zip`
- **All platforms (bigger):** `starlink-gps-jamming-recovery-offline-kit_v1.0.4_all-platforms.zip`

For verification, also download the matching:
- `…zip.sha256` (required)
- `…zip.sshsig` (optional, if present)

### Security & verification (read this first)
#### IRAN / HIGH‑RISK WARNING (IRGC / Sepah) — VERIFY SHA‑256
**Assume a modified copy with injected malware may be redistributed. Verify the Release ZIP SHA‑256 before you extract or run anything.**

If you downloaded this from GitHub Releases:
1) Download the ZIP for your OS **and** the matching `.sha256` file (and the optional `.sshsig`).
2) Verify the ZIP’s SHA‑256 matches the `.sha256` value (see `docs/VERIFY.md`).
3) Extract the ZIP, then run the built‑in integrity check:
   - Windows: `verify_integrity.bat`
   - macOS/Linux: `./verify_integrity.sh`

This project provides **SHA‑256** checksums and may also provide **OpenSSH signatures** (`.sshsig`) for release ZIPs. It does **not** provide PGP/GPG signatures at this time.

### Important (read first)
- Use only on equipment you own/control, and follow local laws and Starlink terms.
- This kit addresses **GPS/GNSS jamming only**. If the Ku/Ka user link is jammed, performance may still be degraded.
- This kit only talks to the dish on your **local network** (`192.168.100.1`). It does not contact external servers.
- Hardware testing is required for full confirmation; this kit is based on public references and is designed to fail safely.

### Quick start (no internet required)
1) Connect your device to **Starlink Wi‑Fi** (same local network as the dish).
2) Run ONE launcher:
   - Windows: double‑click `START_WINDOWS.bat`
   - macOS: double‑click `START_MAC.command`
   - Linux: run `./START_LINUX.sh`
3) Choose **Disable GPS**.
   - If it becomes enabled again after reboot/updates, use **Daemon disable** (re-sends every 5 minutes).
   - Use **Status** to print current output.
   - If Disable GPS fails, run **Probe** and read `docs/OLDER_FIRMWARE.md`.

### What it does (based on public references)
When supported by your Starlink firmware, it sends this local gRPC request:

`{"dishInhibitGps":{"inhibitGps":true}}`

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

<p>این مخزن یک کیت <strong>کاملاً آفلاین</strong> است برای زمانی که <strong>پارازیت GPS/GNSS</strong> باعث می‌شود دیش استارلینک نتواند موقعیت/زمان را درست تشخیص دهد و اتصال دچار مشکل شود.</p>

<p>این کیت شامل موارد زیر است:</p>

<ul>
<li>فایل‌های اجرایی "کلیک و اجرا" برای <strong>Windows / macOS / Linux</strong></li>
<li>باینری آماده‌ی <code>grpcurl</code> (بعد از داشتن پوشه، اینترنت لازم نیست)</li>
<li>حالت <strong>Probe</strong> برای بررسی اینکه فریمور شما فیلد مورد نیاز را دارد یا نه</li>
<li>Schema آفلاین داخل کیت (حتی اگر Reflection غیرفعال باشد هم کار می‌کند)</li>
<li>مستندات دو زبانه (English + فارسی)</li>
</ul>

<h3>امنیت و صحت‌سنجی (حتماً قبل از اجرا)</h3>
<p>قاعده ساده: <strong>قبل از اجرا، صحت‌سنجی کنید</strong>.</p>

<h4>هشدار بسیار مهم برای ایران (IRGC / سپاه) — بررسی SHA‑256</h4>
<p><strong>فرض کنید نسخه‌های دستکاری‌شده با تزریق کد مخرب ممکن است بازنشر شوند. قبل از Extract یا اجرا، حتماً هش SHA‑256 فایل ZIP انتشار را بررسی کنید.</strong></p>

<h3>دانلود (GitHub Releases)</h3>
<p>این کیت را از صفحه رسمی انتشارها (Releases) دریافت کنید:</p>

<p><code>https://github.com/freedom-fighter-1404/starlink-gps-jamming-recovery-offline-kit/releases</code></p>

<p>فقط <strong>یکی</strong> از فایل‌ها را دانلود کنید:</p>
<ul>
<li><strong>Windows:</strong> <code>starlink-gps-jamming-recovery-offline-kit_v1.0.4_windows.zip</code></li>
<li><strong>macOS (Intel + Apple Silicon):</strong> <code>starlink-gps-jamming-recovery-offline-kit_v1.0.4_macos.zip</code></li>
<li><strong>Linux (x86_64 + arm64):</strong> <code>starlink-gps-jamming-recovery-offline-kit_v1.0.4_linux.zip</code></li>
<li><strong>همه سیستم‌ها (حجم بیشتر):</strong> <code>starlink-gps-jamming-recovery-offline-kit_v1.0.4_all-platforms.zip</code></li>
</ul>

<p>برای صحت‌سنجی، فایل‌های کنار آن را هم دانلود کنید:</p>
<ul>
<li><code>…zip.sha256</code> (الزامی)</li>
<li><code>…zip.sshsig</code> (اختیاری، اگر وجود داشت)</li>
</ul>

<p>اگر این کیت را از بخش Releases دریافت کرده‌اید:</p>
<ol>
<li>فایل ZIP مخصوص سیستم‌عامل خود <strong>و</strong> فایل <code>.sha256</code> مربوط به همان ZIP (و در صورت وجود، فایل <code>.sshsig</code>) را دانلود کنید.</li>
<li>هش SHA‑256 فایل ZIP را با مقدار داخل فایل <code>.sha256</code> مقایسه کنید (راهنما: <code>docs/VERIFY_FA.md</code>).</li>
<li>ZIP را Extract کنید و سپس صحت‌سنجی داخلی را اجرا کنید:
<ul>
<li>Windows: <code>verify_integrity.bat</code></li>
<li>macOS/Linux: <code>./verify_integrity.sh</code></li>
</ul>
</li>
</ol>

<p>این پروژه برای صحت‌سنجی از <strong>SHA‑256</strong> استفاده می‌کند و ممکن است برای فایل ZIP انتشار، امضای <strong>OpenSSH</strong> (<code>.sshsig</code>) هم ارائه کند. در حال حاضر امضای PGP/GPG ارائه نمی‌کند.</p>

<h3>نکات مهم (حتماً بخوانید)</h3>
<ul>
<li>فقط روی تجهیزاتی که مالک/مسئول آن هستید استفاده کنید و قوانین محلی و شرایط سرویس استارلینک را رعایت کنید.</li>
<li>این کیت فقط مشکل <strong>پارازیت GPS/GNSS</strong> را هدف می‌گیرد. اگر لینک Ku/Ka هم پارازیت شود، ممکن است باز هم افت کیفیت داشته باشید.</li>
<li>این کیت فقط با دیش روی <strong>شبکه محلی</strong> شما صحبت می‌کند (<code>192.168.100.1</code>) و به هیچ سرور خارجی وصل نمی‌شود.</li>
<li>برای تأیید کامل، تست سخت‌افزار لازم است؛ این کیت بر اساس منابع عمومی تهیه شده و طوری طراحی شده که در صورت ناسازگاری، ایمن و شفاف خطا بدهد.</li>
</ul>

<h3>شروع سریع (بدون نیاز به اینترنت)</h3>
<ol>
<li>به <strong>Wi‑Fi استارلینک</strong> وصل شوید (همان شبکه محلی دیش).</li>
<li>فقط یکی را اجرا کنید:
<ul>
<li>Windows: روی <code>START_WINDOWS.bat</code> دوبار کلیک کنید</li>
<li>macOS: روی <code>START_MAC.command</code> دوبار کلیک کنید</li>
<li>Linux: دستور <code>./START_LINUX.sh</code> را اجرا کنید</li>
</ul>
</li>
<li>گزینه <strong>Disable GPS</strong> را انتخاب کنید.
<ul>
<li>اگر بعد از ریبوت/آپدیت برمی‌گردد، از <strong>Daemon disable</strong> استفاده کنید (هر ۵ دقیقه دوباره ارسال می‌کند).</li>
<li>برای دیدن خروجی وضعیت از <strong>Status</strong> استفاده کنید.</li>
<li>اگر خطا داد، <strong>Probe</strong> را اجرا کنید و <code>docs/OLDER_FIRMWARE_FA.md</code> را بخوانید.</li>
</ul>
</li>
</ol>

<h3>این کیت چه کاری می‌کند؟ (بر اساس منابع عمومی)</h3>
<p>در صورت پشتیبانی فریمور، این درخواست gRPC را به صورت محلی ارسال می‌کند:</p>

<p><code>{"dishInhibitGps":{"inhibitGps":true}}</code></p>

<p>به آدرس:</p>

<p><code>192.168.100.1:9200 SpaceX.API.Device.Device/Handle</code></p>

<h3>صحت‌سنجی (در محیط‌های پرریسک توصیه می‌شود)</h3>
<ul>
<li>Windows: <code>verify_integrity.bat</code> (یا <code>verify_integrity.ps1</code>) را اجرا کنید</li>
<li>macOS/Linux: <code>./verify_integrity.sh</code> را اجرا کنید</li>
<li>راهنمای صحت‌سنجی (Release و هش‌ها): <code>docs/VERIFY_FA.md</code></li>
<li>اطلاعات بیشتر: <code>docs/SECURITY_FA.md</code> و <code>docs/AUDIT.md</code> و <code>docs/AUDIT_FA.md</code></li>
</ul>

</div>
