# LarpingHub

Hub Roblox ringan untuk headless, korblox, dan puluhan aksesoris katalog.
Dibuat oleh **Varen**.

Tekan tombol **Y** untuk membuka / menutup hub.

## Fitur

- Floating ball (bisa digeser)
- Tab **Credit** / **Avatar** / **Automatic**
- **Headless** & **Korblox** (memakai `HumanoidDescription`, plus fallback visual kalau game memblokirnya)
- Equip puluhan aksesoris katalog (8-Bit, Horns, dll)
- **Auto Equip** — re-apply otomatis setiap respawn

## Cara Pakai

Tempel baris berikut ke executor Roblox, lalu Execute:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/VarenYuta/LarpingHub/main/LarpingHub.lua"))()
```

File loader-nya juga tersedia di [loader.lua](loader.lua).

## Catatan

- Butuh executor yang mendukung `HttpGet`, `writefile`, dan `InsertService`.
- Fallback korblox (R15) bersifat best-effort; ukuran mesh bisa berbeda tergantung body scale.

## Lisensi

Bebas dipakai dan dibagikan. Sertakan kredit bila memungkinkan.
