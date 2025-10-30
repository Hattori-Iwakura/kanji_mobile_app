# Permissions Setup - Translate Feature

## ✅ Đã thêm Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<!-- Permissions for Translate Feature -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
```

**Giải thích:**
- `INTERNET`: Cần thiết cho Google Translate API
- `RECORD_AUDIO`: Bắt buộc cho Speech-to-Text (microphone access)
- `BLUETOOTH`: Hỗ trợ Bluetooth headset/microphone
- `BLUETOOTH_CONNECT`: Android 12+ cần permission này cho Bluetooth

### iOS (`ios/Runner/Info.plist`)

```xml
<!-- Permissions for Translate Feature -->
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice input and speech recognition in translation feature</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition for voice-to-text translation</string>
```

**Giải thích:**
- `NSMicrophoneUsageDescription`: Hiển thị khi app xin quyền microphone
- `NSSpeechRecognitionUsageDescription`: Hiển thị khi app sử dụng speech recognition

## Runtime Permission Handling

App sử dụng `permission_handler` package để xin quyền runtime:

```dart
// Trong SpeechToTextService.initialize()
final status = await Permission.microphone.request();
if (!status.isGranted) {
  throw Exception('Microphone permission not granted');
}
```

### Permission Flow

1. **First Launch**:
   - User tap microphone button (🎤)
   - App request microphone permission
   - System dialog hiển thị với message từ Info.plist/Manifest
   - User accept/deny

2. **Permission Granted**:
   - STT service khởi tạo thành công
   - Microphone icon chuyển sang red khi listening
   - Speech recognition hoạt động

3. **Permission Denied**:
   - Exception thrown: "Microphone permission not granted"
   - SnackBar hiển thị error
   - User cần vào Settings để enable permission manually

## Testing Permissions

### Android
```bash
# Check permissions
adb shell dumpsys package com.example.kanji_mobile_app | grep permission

# Grant permission manually
adb shell pm grant com.example.kanji_mobile_app android.permission.RECORD_AUDIO

# Revoke permission
adb shell pm revoke com.example.kanji_mobile_app android.permission.RECORD_AUDIO

# Reset permissions
adb shell pm reset-permissions
```

### iOS
```bash
# Check permissions (xcode console)
# iOS không có command line để check permissions

# Reset permissions
# Settings > General > Reset > Reset Location & Privacy
```

### Manual Testing
1. **First time**:
   - Open app
   - Navigate to Translate page
   - Tap microphone button
   - Verify permission dialog shows
   - Accept permission
   - Verify mic icon turns red
   - Speak and verify text appears

2. **Permission denied**:
   - Deny permission in dialog
   - Verify error message shows
   - Open Settings
   - Enable microphone permission
   - Return to app
   - Tap mic again - should work

3. **After permission granted**:
   - Close and reopen app
   - Navigate to Translate
   - Tap mic - should work immediately (no dialog)

## Troubleshooting

### Android Issues

**Issue**: "Permission denied" on Android 6.0+
- **Solution**: Ensure runtime permission request is working
- Check `permission_handler` version in pubspec.yaml
- Rebuild app: `flutter clean && flutter build apk`

**Issue**: Microphone not working on emulator
- **Solution**: Use physical device - emulators don't have real microphones
- Or use Android Studio AVD with host audio input

**Issue**: BLUETOOTH_CONNECT permission error on Android 12+
- **Solution**: Added in manifest - rebuild app

### iOS Issues

**Issue**: Permission dialog not showing
- **Solution**: Check Info.plist has correct keys
- Verify strings are not empty
- Rebuild: `flutter clean && flutter build ios`

**Issue**: "This app has crashed because it attempted to access privacy-sensitive data..."
- **Solution**: Missing NSMicrophoneUsageDescription
- Add to Info.plist and rebuild

**Issue**: Speech recognition not available
- **Solution**: 
  - Check device iOS version (iOS 10+)
  - Verify Siri & Dictation enabled in Settings
  - Some languages may not be available

### General Issues

**Issue**: STT not working on emulator
- **Solution**: Use physical device - emulators have limited STT support

**Issue**: "Speech recognition initialization failed"
- **Solution**:
  - Check internet connection (some STT needs online)
  - Verify language support on device
  - Check microphone hardware

**Issue**: TTS works but STT doesn't
- **Solution**: Different permissions - check microphone permission specifically

## Best Practices

### 1. Explain Why Permission Needed
- Show explanation dialog before requesting
- Make it clear what feature needs permission
- Link to Settings if denied

### 2. Handle Permission Denial Gracefully
```dart
if (!permissionGranted) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Microphone Permission'),
      content: Text(
        'Voice input requires microphone access. '
        'Please enable it in Settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => openAppSettings(),
          child: Text('Open Settings'),
        ),
      ],
    ),
  );
}
```

### 3. Test on Multiple Devices
- Different Android versions (6, 10, 12, 13)
- Different iOS versions (13, 14, 15, 16)
- Various manufacturers (Samsung, Xiaomi, Oppo)

### 4. Inform Users About Microphone Usage
- Show mic icon state clearly
- Display "Listening..." text
- Provide stop button when active

## Security Notes

⚠️ **Important**:
- Microphone permission is sensitive data
- Only request when needed (not on app startup)
- Audio is processed locally by speech recognition
- No audio is sent to our servers
- Google Translate API only receives text, not audio

## Platform Support

| Platform | Microphone | Speech Recognition | TTS |
|----------|------------|-------------------|-----|
| Android 6+ | ✅ | ✅ | ✅ |
| iOS 10+ | ✅ | ✅ | ✅ |
| Web | ⚠️ | ⚠️ | ⚠️ |
| Windows | ❌ | ❌ | ❌ |
| macOS | ⚠️ | ⚠️ | ⚠️ |
| Linux | ❌ | ❌ | ❌ |

✅ = Fully supported
⚠️ = Partial support / Browser dependent
❌ = Not supported

## Changes Made

### 1. AndroidManifest.xml
- Added 4 permissions at manifest level
- Required for microphone access and Bluetooth audio

### 2. Info.plist
- Added 2 usage description keys
- Explains to user why permissions needed
- Required by Apple App Store

### 3. SpeechToTextService
- Fixed deprecated API warnings
- Changed to `SpeechListenOptions` wrapper
- Better error handling

## Next Steps

1. ✅ Permissions added to manifest files
2. ✅ Fixed deprecated API usage
3. 🔄 Test on physical device
4. 📋 Submit app review with permission justification
5. 📝 Update app store description mentioning voice features

## App Store Requirements

### Google Play Store
- Declare permissions in manifest ✅
- Privacy Policy explaining data usage ❌ (TODO)
- Prominent disclosure before permission request ✅

### Apple App Store
- Usage descriptions in Info.plist ✅
- Privacy Policy ❌ (TODO)
- Clear explanation of microphone usage ✅
- No recording without user consent ✅

## Status: ✅ Ready for Testing

All required permissions have been added. App is ready to test Speech-to-Text feature on physical devices.
