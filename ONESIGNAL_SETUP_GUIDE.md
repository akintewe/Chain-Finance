# OneSignal Push Notifications Setup Guide

This guide provides step-by-step instructions to complete the OneSignal integration for your Flutter app.

## Prerequisites Completed ✅

The following have already been set up in your project:

1. ✅ OneSignal Flutter plugin added to `pubspec.yaml`
2. ✅ Android permissions and configuration added to `AndroidManifest.xml`
3. ✅ iOS configuration added to `Info.plist`
4. ✅ OneSignal service class created (`lib/services/onesignal_service.dart`)
5. ✅ OneSignal initialization added to `main.dart`
6. ✅ Notification settings screen created
7. ✅ CocoaPods dependencies installed for iOS

## Next Steps Required

### Step 1: Create OneSignal Account & App

1. **Visit OneSignal Dashboard**
   - Go to [https://onesignal.com/](https://onesignal.com/)
   - Create a free account or sign in

2. **Create New App**
   - Click "New App/Website"
   - Enter your app name: "Nexa Prime"
   - Select "Mobile App"

3. **Note Your App ID**
   - Once created, copy your OneSignal App ID (it looks like: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`)

### Step 2: Configure Android Platform

1. **In OneSignal Dashboard:**
   - Select "Android" platform
   - You'll need your Firebase Server Key and Sender ID

2. **Firebase Setup (if not already done):**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use existing one
   - Add Android app with package name: `com.chainfinance.app`
   - Download `google-services.json` and place it in `android/app/`

3. **Get Firebase Credentials:**
   - In Firebase Console, go to Project Settings > Cloud Messaging
   - Copy the "Server Key" and "Sender ID"
   - Enter these in OneSignal Android configuration

4. **Update Android Configuration:**
   - Open `android/app/src/main/AndroidManifest.xml`
   - Replace `YOUR_ONESIGNAL_APP_ID` with your actual OneSignal App ID
   - Replace `YOUR_GOOGLE_PROJECT_NUMBER` with your Firebase Sender ID

### Step 3: Configure iOS Platform

1. **In OneSignal Dashboard:**
   - Select "iOS" platform
   - Upload your iOS Push Certificate or use iOS Push Key

2. **iOS Push Certificate Setup:**
   - Open Keychain Access on Mac
   - Go to Certificate Assistant > Request a Certificate from a Certificate Authority
   - Save the CSR file
   - Go to Apple Developer Console > Certificates
   - Create new certificate > Apple Push Notification service SSL
   - Upload the CSR file and download the certificate
   - Upload this certificate to OneSignal

3. **Update iOS Configuration:**
   - Open `ios/Runner/Info.plist`
   - Replace `YOUR_ONESIGNAL_APP_ID` with your actual OneSignal App ID

4. **Xcode Configuration:**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select the Runner target
   - Go to "Signing & Capabilities"
   - Add "Push Notifications" capability
   - Add "Background Modes" capability and check "Remote notifications"

### Step 4: Update App Code

1. **Update OneSignal App ID in Service:**
   ```bash
   # Open lib/services/onesignal_service.dart
   # Replace "YOUR_ONESIGNAL_APP_ID" with your actual App ID
   ```

2. **Add Navigation to Notification Settings:**
   - You can add a button in your Settings screen to navigate to notification settings:
   ```dart
   // In your settings screen, add:
   GestureDetector(
     onTap: () => Get.toNamed(Routes.notificationSettings),
     child: // Your notification settings tile
   )
   ```

### Step 5: Test the Integration

1. **Build and Install Debug Version:**
   ```bash
   flutter run
   ```

2. **Test Notification Permission:**
   - Open the app
   - Check if notification permission dialog appears
   - Grant permission when prompted

3. **Send Test Notification:**
   - Go to OneSignal Dashboard
   - Navigate to "Messages" > "Push"
   - Click "New Push"
   - Enter a test message
   - Send to "All Users" or specific segments

4. **Test Deep Linking (Optional):**
   - In OneSignal dashboard, add custom data in "Advanced Settings"
   - Handle the data in `_handleNotificationClick` method in the service

### Step 6: Production Configuration

1. **Android Release Configuration:**
   - Ensure you have a signed release APK
   - The Firebase configuration works for both debug and release

2. **iOS Production Configuration:**
   - Create a Production Push Certificate (not Development)
   - Upload to OneSignal
   - Test with TestFlight builds

### Step 7: Advanced Features (Optional)

1. **User Segmentation:**
   ```dart
   // Set user tags for targeted notifications
   OneSignalService.sendTags({
     'user_type': 'premium',
     'preferred_currency': 'USD',
     'app_version': '1.0.0',
   });
   ```

2. **External User ID:**
   ```dart
   // Link OneSignal user with your user system
   OneSignalService.setExternalUserId(userController.currentUser.id);
   ```

3. **Custom Notification Sounds:**
   - Add sound files to `android/app/src/main/res/raw/`
   - Add sound files to iOS bundle
   - Configure in OneSignal dashboard

## Configuration Files Summary

### Files Already Updated:
- ✅ `pubspec.yaml` - OneSignal dependency added
- ✅ `android/app/src/main/AndroidManifest.xml` - Permissions and meta-data added
- ✅ `ios/Runner/Info.plist` - iOS configuration added
- ✅ `lib/main.dart` - OneSignal initialization added
- ✅ `lib/services/onesignal_service.dart` - Service class created
- ✅ `lib/views/home/notification_settings_screen.dart` - Settings screen created
- ✅ `lib/routes/routes.dart` - Route added

### Files You Need to Update:
- 📝 `android/app/src/main/AndroidManifest.xml` - Replace placeholder App ID
- 📝 `ios/Runner/Info.plist` - Replace placeholder App ID
- 📝 `lib/services/onesignal_service.dart` - Replace placeholder App ID

## Troubleshooting

### Common Issues:

1. **iOS Build Errors:**
   ```bash
   cd ios && pod install --repo-update
   ```

2. **Android Build Errors:**
   - Ensure Firebase configuration is correct
   - Check package name matches everywhere

3. **Notifications Not Received:**
   - Check app is not in "Do Not Disturb" mode
   - Verify notification permissions are granted
   - Check OneSignal dashboard for delivery reports

4. **Permission Issues:**
   - Test on real device (simulator may have limitations)
   - Check device notification settings

### Testing Commands:

```bash
# Clean and rebuild
flutter clean
flutter pub get
cd ios && pod install
flutter run

# Build release versions
flutter build apk --release
flutter build ios --release
```

## Security Notes

- Keep your OneSignal App ID and Firebase Server Key secure
- Don't commit sensitive keys to version control
- Consider using environment variables for production builds

## Support

- OneSignal Documentation: [https://documentation.onesignal.com/](https://documentation.onesignal.com/)
- Flutter Plugin Docs: [https://pub.dev/packages/onesignal_flutter](https://pub.dev/packages/onesignal_flutter)

---

**Next Action:** 
1. Create OneSignal account and get your App ID
2. Replace all placeholder App IDs in the configuration files
3. Test the integration with debug builds 