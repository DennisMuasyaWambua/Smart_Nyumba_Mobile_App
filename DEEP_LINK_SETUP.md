# Deep Link Setup for Pesapal Payment Redirects

This guide explains how to configure and use deep linking for Pesapal payment redirects in the Smart Nyumba app.

## What's Been Configured

### 1. Android Configuration
**File**: `android/app/src/main/AndroidManifest.xml`

Added deep link intent filter:
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="smartnyumba"
        android:host="payment-complete" />
</intent-filter>
```

### 2. iOS Configuration
**File**: `ios/Runner/Info.plist`

Added URL scheme configuration:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.example.smart_nyumba</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>smartnyumba</string>
        </array>
    </dict>
</array>
```

### 3. Dependencies
**File**: `pubspec.yaml`

Added package:
```yaml
dependencies:
  app_links: ^6.3.2
```

**Note**: We use `app_links` (the modern replacement for the discontinued `uni_links` package).

Run:
```bash
flutter pub get
```

### 4. Deep Link Service
**File**: `lib/utils/services/deep_link_service.dart`

Core service that listens for deep links and processes payment redirects.

**File**: `lib/utils/services/payment_redirect_handler.dart`

High-level handler that shows appropriate messages and navigates users after payment.

## How to Use

### Option 1: Simple Integration (Recommended)

Update your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

import 'screens/admin/_admin.dart';
import 'screens/authentication/_auth.dart';
import 'screens/caretaker/_caretaker.dart';
import 'screens/landlord/_landlord.dart';
import 'screens/tenant/_tenant.dart';
import 'utils/providers.dart';
import 'utils/providers/shared_preference_builder.dart';
import 'utils/routes.dart';
import 'utils/theme.dart';
import 'utils/services/payment_redirect_handler.dart'; // Add this import

Future main() async {
  await dotenv.load(fileName: ".env");
  await SharedPrefrenceBuilder.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {  // Change to StatefulWidget
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize deep link handler when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PaymentRedirectHandler.initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    late DateTime? tokenExpirationDate;
    late bool isTokenValid = false;

    if (SharedPrefrenceBuilder.getExpirationTime != null) {
      tokenExpirationDate = DateTime.parse(SharedPrefrenceBuilder.getExpirationTime!);
      isTokenValid = tokenExpirationDate.isAfter(DateTime.now());
      !isTokenValid ? SharedPrefrenceBuilder.clearInvalidToken() : null;
    }

    Widget getHomeScreen() {
      if (SharedPrefrenceBuilder.getUserToken == null || !isTokenValid) {
        return const Login();
      }

      final role = SharedPrefrenceBuilder.getUserRole;
      switch (role) {
        case "tenant":
          return const TenantDashboard();
        case "landlord":
          return const LandlordDashboard();
        case "caretaker":
          return const CaretakerDashboard();
        default:
          return const AdminDashboard();
      }
    }

    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        home: getHomeScreen(),
        routes: routes,
        theme: lightTheme,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
```

### Option 2: Custom Integration

If you want custom handling:

```dart
import 'package:smart_nyumba/utils/services/deep_link_service.dart';

// In your app initialization
DeepLinkService().initialize(
  onPaymentComplete: (paymentType) {
    if (paymentType == 'activation') {
      // Handle landlord activation payment completion
      // Show custom message, navigate to specific screen, etc.
      print('Activation payment completed!');
      // Navigate to activation success screen
    } else if (paymentType == 'service') {
      // Handle service charge payment completion
      print('Service charge payment completed!');
      // Navigate to transactions screen
    } else if (paymentType == 'rent') {
      // Handle rent payment completion
      print('Rent payment completed!');
      // Navigate to rent transactions screen
    }
  },
);
```

## How It Works

### Payment Flow

1. **User initiates payment** (activation/rent/service charge)
   - App calls backend API
   - Backend returns Pesapal checkout URL
   - App opens URL in WebView or browser

2. **User completes payment on Pesapal**
   - User enters payment details
   - Pesapal processes payment

3. **Pesapal redirects back to app**
   - Redirect URL: `smartnyumba://payment-complete?type=xxx`
   - App deep link handler catches the redirect
   - Shows success message
   - Navigates to appropriate screen

4. **Backend receives IPN notification**
   - Pesapal sends notification to: `https://api.smartnyumba.tech/apps/api/v1/tenant-services/pesapal/ipn/`
   - Backend processes payment
   - Updates transaction status
   - Activates account (for activation payments)

### Deep Link Format

The app handles these deep link URLs:

- **Activation**: `smartnyumba://payment-complete?type=activation`
- **Service Charge**: `smartnyumba://payment-complete?type=service`
- **Rent Payment**: `smartnyumba://payment-complete?type=rent`

## Testing

### Test on Android

Using ADB:
```bash
adb shell am start -W -a android.intent.action.VIEW -d "smartnyumba://payment-complete?type=activation"
```

### Test on iOS

Using xcrun:
```bash
xcrun simctl openurl booted "smartnyumba://payment-complete?type=activation"
```

### Test in Browser

During development, you can test by opening these URLs in Chrome on device:
- `smartnyumba://payment-complete?type=activation`
- `smartnyumba://payment-complete?type=service`
- `smartnyumba://payment-complete?type=rent`

## Troubleshooting

### Deep link not working on Android

1. Verify AndroidManifest.xml has the intent filter
2. Reinstall the app (uninstall first)
3. Check logcat: `adb logcat | grep -i "deep"`

### Deep link not working on iOS

1. Verify Info.plist has CFBundleURLTypes
2. Clean build folder: `flutter clean`
3. Rebuild: `flutter build ios`

### Payment redirect opens browser instead of app

Make sure:
1. The deep link scheme (`smartnyumba://`) is correctly configured
2. The app is installed on the device
3. The Pesapal redirect URL matches exactly

## Navigation Routes

Make sure these routes exist in your `utils/routes.dart`:

```dart
'/login': (context) => const Login(),
'/tenant-dashboard': (context) => const TenantDashboard(),
'/landlord-dashboard': (context) => const LandlordDashboard(),
```

## Security Considerations

- The deep link only handles UI navigation
- Payment verification is done server-side via IPN
- Never trust client-side payment status
- Always verify payment status from backend before granting access

## Support

If you encounter issues:
1. Check the console logs for errors
2. Verify all configuration files are updated
3. Test with the ADB/xcrun commands first
4. Ensure `flutter pub get` was run after adding uni_links

---

**Note**: This setup is complete and ready to use. Just update your `main.dart` as shown in Option 1 above, then run `flutter pub get` and rebuild the app.
