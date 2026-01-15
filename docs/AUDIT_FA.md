# یادداشت‌های بررسی/صحت‌سنجی (Audit)

این سند توضیح می‌دهد هنگام آماده‌سازی این کیت چه چیزهایی بررسی شده و چه مواردی را بدون دسترسی به سخت‌افزار استارلینک نمی‌توان ۱۰۰٪ تأیید کرد.

## حقایق کلیدی

### ۱) آدرس/پورت محلی دیش
ترمینال‌های استارلینک معمولاً یک رابط محلی در `192.168.100.1` دارند.

### ۲) درخواست غیرفعال‌سازی GPS وجود دارد (و ساختارش مشخص است)
فیلد `dish_inhibit_gps` با زیر‌فیلد `inhibit_gps` در فریمورهای پشتیبانی‌شده وجود دارد.

به همین دلیل این کیت این پیام را ارسال می‌کند:
`{"dishInhibitGps":{"inhibitGps":true}}`

به این آدرس/متد:
`192.168.100.1:9200 SpaceX.API.Device.Device/Handle`

### ۳) Reflection اختیاری است (Schema آفلاین داخل کیت)
بعضی فریمورها gRPC reflection را غیرفعال می‌کنند. این کیت یک Schema حداقلی داخل خودش دارد تا بدون Reflection هم بتواند API محلی را صدا بزند:
- `proto/starlink_minimal.proto` (Schema قابل خواندن)
- `proto/starlink.protoset` (فایل کامپایل‌شده برای `grpcurl`)

### ۴) گزینه رسمی داخل اپ (در صورت پشتیبانی)
در بعضی نسخه‌های اپلیکیشن استارلینک، یک گزینه‌ی Debug وجود دارد:
- **"Use Starlink positioning exclusively"**

طبق گزارش‌های عمومی، فعال کردن این گزینه می‌تواند به ترمینال بگوید **از GPS استفاده نکند** و در نتیجه پارازیت GPS بی‌اثر شود. هزینه‌های احتمالی گزارش‌شده:
- ممکن است زمان شروع/پیدا کردن ماهواره‌ها طولانی‌تر شود.
- ممکن است در حالت حرکت (خودرو/قایق) خوب کار نکند.

### ۵) بهبودهای فیزیکی برای دریافت GPS به‌صورت عمومی مستند شده‌اند
تغییرات آنتن GPS خارجی و برخی بهبودهای دریافت (بسته به مدل) به‌صورت عمومی مستند شده و شامل نتایج تست هستند.

### ۶) ممکن است `inhibitGps` به‌عنوان اقدام ضد اسپوفینگ دیده شود (گزارش عمومی)
بعضی گزارش‌های عمومی از تله‌متری Debug نشان می‌دهند در حالی که `gpsValid: true` و تعداد ماهواره‌ها طبیعی است، مقدار `inhibitGps: true` هم دیده می‌شود و آن را به‌عنوان غیرفعال شدن موقعیت‌یابی مبتنی بر GPS به دلیل اسپوفینگ/جعل سیگنال تفسیر می‌کنند.

این یک سند رسمیِ سازنده نیست و نباید قطعی فرض شود — اما با این ایده سازگار است که `inhibitGps` می‌تواند به‌صورت خودکار و برای ایمنی توسط ترمینال فعال شود.

### ۷) قدیمی بودن فریمور می‌تواند بازیابی را سخت کند (گزارش عمومی)
طبق برخی گزارش‌های عمومی، ممکن است برای ادامه کار روی شبکه، نسخه‌های حداقلی فریمور لازم باشد و تجهیزاتی که مدت طولانی خاموش/بدون استفاده بوده‌اند، قبل از اتصال به آپدیت نیاز داشته باشند.

## به چه چیزی عمداً تکیه نمی‌کنیم
- “payload” های باینری “همه‌کاره” برای gRPC‑web روی پورت `9201` که قابل صحت‌سنجی روی Schema زنده نیستند؛ این موارد زیاد بازنشر می‌شوند ولی ممکن است برای فریمور شما غلط باشند.

## چه چیزهایی را اینجا نمی‌توان ۱۰۰٪ تأیید کرد (بدون سخت‌افزار)
- اینکه فریمور شما از `dish_inhibit_gps` و/یا گزینه‌ی “positioning exclusively” در اپ پشتیبانی می‌کند یا نه (از **Probe** و تست عملی استفاده کنید).
- اینکه غیرفعال کردن GPS در شرایط پارازیت شما واقعاً اتصال را برمی‌گرداند یا نه (به نوع/قدرت پارازیت، فاصله، پارازیت GPS در برابر پارازیت لینک، و محیط آنتن بستگی دارد).

## منابع عمومی برای صحت‌سنجی
- IP محلی استارلینک + نمونه‌های gRPC: https://github.com/sparky8512/starlink-grpc-tools
- استفاده از `dish_inhibit_gps` در کد (Commit ثابت): https://github.com/sparky8512/starlink-grpc-tools/blob/ca8c1d5b5ee6fad0d8c1c9b146711e084889f03a/dish_control.py
- شماره فیلدها + نام سرویس/پیام‌ها (proto با Commit ثابت):
  - https://raw.githubusercontent.com/andywwright/starlink-grpc-client/ad72ecdda352e6af288d7bc1ef4bdc29193c68b4/protos/starlink_protos/spacex/api/device/device.proto
  - https://raw.githubusercontent.com/andywwright/starlink-grpc-client/ad72ecdda352e6af288d7bc1ef4bdc29193c68b4/protos/starlink_protos/spacex/api/device/dish.proto
- متن گزینه اپ + توضیح درباره GNSS/jamming (مقاله + نظرات): https://olegkutkov.me/2023/11/07/connecting-external-gps-antenna-to-the-starlink-terminal/
- خلاصه‌ی ثانویه درباره تغییرات آنتن: https://hackaday.com/2024/03/06/gps-antenna-mods-make-starlink-terminal-immune-to-jammers/
- گزارش عمومی تله‌متری درباره `gpsStats.inhibitGps` در ایران: https://github.com/narimangharib/starlink-iran-gps-spoofing/blob/main/starlink-iran.md
- گزارش عمومی درباره حداقل فریمور/آپدیت‌های اجباری: https://www.rvmobileinternet.com/some-starlink-terminals-require-mandatory-software-updates-to-continue-to-function-on-starlinks-network/
