# Release Guide

## App Store / Play Store Requirements

### Bundle Identifiers

| Platform | Identifier |
|----------|------------|
| iOS | `com.gymapp.mobile` |
| Android | `com.gymapp.mobile` |

### Signing

**iOS:**
1. Create App ID in Apple Developer portal
2. Generate provisioning profiles (development & distribution)
3. Store signing certificates in macOS Keychain
4. Configure Xcode project with team and profiles

**Android:**
1. Generate keystore:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Store keystore securely (NOT in repo)
3. Configure `android/key.properties` (gitignored)
4. Reference in `android/app/build.gradle`

### In-App Purchases

> ⚠️ **IMPORTANT**: iOS and Android require using their native IAP systems for digital goods (coins, stickers). External payment links are prohibited.

**Requirements:**
1. Configure IAP products in App Store Connect / Google Play Console
2. Implement client-side purchase flow with StoreKit / Google Billing
3. **Server-side receipt validation** - do NOT trust client-only validation
4. Handle subscription lifecycle (if applicable)

### Privacy Policy

Required for both stores. Must include:
- Data collected (email, workout data)
- How data is used
- Data retention policy
- Third-party sharing (analytics, etc.)
- Contact information
- GDPR/CCPA rights

**Placeholder URL**: `https://gymapp.com/privacy`

### Manifest Permissions

**Android (`android/app/src/main/AndroidManifest.xml`):**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<!-- Optional for background sync -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```

**iOS (`ios/Runner/Info.plist`):**
- `NSCameraUsageDescription` (if using camera)
- `NSPhotoLibraryUsageDescription` (if accessing photos)
- `NSHealthShareUsageDescription` (if integrating HealthKit)

### Store Listing Assets

| Asset | iOS | Android |
|-------|-----|---------|
| Icon | 1024x1024 | 512x512 |
| Screenshots | 6.5" + 5.5" | Phone + Tablet |
| Feature Graphic | - | 1024x500 |

### Image Size Guidelines

**Stickers:**
- Format: WebP or PNG
- Size: 512x512 pixels
- Max file size: 500KB

## Build Commands

```bash
# iOS Release
cd app
flutter build ios --release

# Android Release
cd app
flutter build appbundle --release
```

## Pre-Release Checklist

See `release/checklist.md` for full verification steps.
