# Placeholder Assets

This directory contains placeholder images for development.

## Files

- `placeholder_800x600_gray.png` - Gray placeholder (800x600)
- `placeholder_512x512_surface.png` - Surface color placeholder (512x512)
- `placeholder_sticker_256.png` - Sticker placeholder (256x256)

## Generating Placeholders

If PNG files are missing, generate them using ImageMagick:

```bash
# Gray 800x600
convert -size 800x600 xc:#1A1A1A placeholder_800x600_gray.png

# Surface 512x512
convert -size 512x512 xc:#222222 placeholder_512x512_surface.png

# Sticker 256x256
convert -size 256x256 xc:#FC4C02 placeholder_sticker_256.png
```

Or use online tools:
- https://placeholder.com/800x600/1a1a1a/ffffff
- https://dummyimage.com/512x512/222222/ffffff

## Image Size Guidelines

| Asset Type | Recommended Size | Format |
|------------|-----------------|--------|
| Onboarding | 800x600 | PNG |
| Stickers | 512x512 | WebP |
| Icons | 256x256 | PNG |
| Avatars | 128x128 | PNG/JPEG |
