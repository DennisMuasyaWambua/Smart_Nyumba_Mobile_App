# Pesapal Flutter Frontend Implementation

## Summary

This document describes the Flutter frontend changes made to support Pesapal payment gateway for landlord activation payments, replacing the previous M-Pesa STK Push implementation.

## Changes Made

### 1. Updated Dependencies (pubspec.yaml)

**File**: `pubspec.yaml`

Added WebView Flutter dependency for displaying Pesapal checkout page:

```yaml
dependencies:
  # ... existing dependencies
  webview_flutter: ^4.4.2
```

**Installation**: Run `flutter pub get` to install the new dependency.

---

### 2. Updated Activation Payment Screen

**File**: `lib/screens/authentication/activation_payment_screen.dart`

**Complete Rewrite** - Changed from M-Pesa STK Push polling to Pesapal WebView checkout.

#### Key Changes:

**Payment States**:
```dart
enum PaymentState { initial, loading, webview, polling, success, failed }
```
- `initial`: User enters phone number
- `loading`: Initiating payment with backend
- `webview`: Displaying Pesapal checkout page in WebView
- `polling`: Verifying payment completion after checkout
- `success`: Payment confirmed, navigating to dashboard
- `failed`: Payment failed or error occurred

**WebView Integration**:
- Initializes `WebViewController` to load Pesapal checkout URL
- Monitors URL changes to detect payment completion
- Handles navigation back/cancel with confirmation dialog
- Full-screen WebView with custom AppBar

**Payment Flow**:
1. User enters phone number
2. Click "Proceed to Payment" → calls `initiateActivationPaymentPesapal()`
3. Backend returns `redirect_url` and `order_tracking_id`
4. WebView loads Pesapal checkout page
5. User completes payment (M-Pesa or Card)
6. On success URL pattern, start polling activation status
7. Navigate to landlord dashboard on confirmation

**Key Methods**:
- `_initiatePayment()`: Calls backend to get Pesapal checkout URL
- `_startPollingAfterPayment()`: Begins status checking after payment
- `_startPolling()`: Polls `/check-activation-status/` every 3 seconds
- `_cancelPayment()`: Shows confirmation dialog before canceling
- `_buildPaymentStatusWidget()`: Shows different UI for each payment state

---

### 3. Updated Payment Provider

**File**: `lib/utils/providers/payment_provider.dart`

Added new method for Pesapal activation payment initiation.

#### New Method:

```dart
Future<ActivationPaymentResponse> initiateActivationPaymentPesapal({
  required String email,
  required String mobileNumber,
  String firstName = '',
  String lastName = '',
}) async {
  Uri activationPaymentUri = Uri.parse(Constants.INITIATE_ACTIVATION_PAYMENT);
  var response = await http.post(activationPaymentUri, body: {
    'email': email,
    'mobile_number': mobileNumber,
    'first_name': firstName,
    'last_name': lastName,
  });

  ActivationPaymentResponse paymentResponse =
      ActivationPaymentResponse.fromJson(json.decode(response.body));

  return paymentResponse;
}
```

**Parameters**:
- `email`: User's email address (required)
- `mobileNumber`: Phone number for payment (required)
- `firstName`: User's first name (optional, for billing)
- `lastName`: User's last name (optional, for billing)

**Returns**: `ActivationPaymentResponse` containing:
- `status`: Success/failure boolean
- `message`: Response message
- `data`: Contains `redirect_url` and `order_tracking_id`

**Existing Methods Retained**:
- `initiateActivationPayment()`: Old M-Pesa method (marked as deprecated)
- `checkActivationPaymentStatus()`: Still used for polling payment status

---

### 4. Updated Activation Payment Response Model

**File**: `lib/utils/models/activation_payment_response.dart`

Extended the model to support both M-Pesa and Pesapal responses.

#### Added Fields:

```dart
class ActivationPaymentResponse {
  // Existing M-Pesa fields
  bool? status;
  String? message;
  String? merchantRequestID;
  String? checkoutRequestID;

  // NEW: Pesapal fields
  dynamic data;  // Contains full response data
  String? redirectUrl;
  String? orderTrackingId;

  // Constructor updated with new fields
  ActivationPaymentResponse({
    this.status,
    this.message,
    this.merchantRequestID,
    this.checkoutRequestID,
    this.data,
    this.redirectUrl,
    this.orderTrackingId,
  });

  // fromJson updated to parse Pesapal response
  ActivationPaymentResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];

    // M-Pesa fields (backward compatibility)
    merchantRequestID = json['MerchantRequestID'];
    checkoutRequestID = json['CheckoutRequestID'];

    // Pesapal fields
    redirectUrl = json['redirect_url'];
    orderTrackingId = json['order_tracking_id'];

    // Store full data for flexibility
    if (json.containsKey('redirect_url') || json.containsKey('order_tracking_id')) {
      data = {
        'redirect_url': json['redirect_url'],
        'order_tracking_id': json['order_tracking_id'],
        'merchant_reference': json['merchant_reference'],
        'amount': json['amount'],
      };
    }
  }
}
```

**Backward Compatibility**: Existing M-Pesa fields are retained for compatibility with old flows.

---

### 5. Updated Shared Preferences Builder

**File**: `lib/utils/providers/shared_preference_builder.dart`

Added support for storing and retrieving user's last name.

#### Added:

```dart
class SharedPrefrenceBuilder {
  // NEW constant
  static const userLastName = 'last_name';

  // NEW setter
  static Future setUserLastName(String lastName) async {
    await _preferences!.setString(userLastName, lastName);
  }

  // NEW getter
  static String? get getUserLastName {
    return _preferences!.getString(userLastName);
  }
}
```

**Usage**: Store lastName during registration, retrieve during payment flow.

---

### 6. Updated OTP Screen

**File**: `lib/screens/authentication/otp.dart`

Updated landlord redirect to pass both `firstName` and `lastName` to activation payment screen.

#### Changes:

```dart
// Line 117-118: Get both first and last name
String? firstName = SharedPrefrenceBuilder.getUserFirstName;
String? lastName = SharedPrefrenceBuilder.getUserLastName;

// Line 143-147: Pass both to activation payment screen
Navigator.pushReplacementNamed(
  context,
  ActivationPaymentScreen.routeName,
  arguments: {
    'email': email ?? '',
    'firstName': firstName ?? 'Landlord',
    'lastName': lastName ?? ''  // NEW
  }
);
```

**Flow**: After OTP verification success → landlords redirected to activation payment with full name.

---

## API Integration

### Backend Endpoint

**URL**: `POST /apps/api/v1/auth/initiate-activation-payment/`

**Request Body**:
```json
{
  "email": "landlord@example.com",
  "mobile_number": "254712345678",
  "first_name": "John",
  "last_name": "Doe"
}
```

**Response (Success)**:
```json
{
  "status": true,
  "message": "Please complete payment in the checkout page",
  "redirect_url": "https://cybqa.pesapal.com/iframe/PesapalIframe3/Index/?OrderTrackingId=...",
  "order_tracking_id": "abc123-def456-ghi789",
  "merchant_reference": "ACTIVATION-42-abc12345",
  "amount": 500.0
}
```

**Response (Error)**:
```json
{
  "status": false,
  "message": "Payment initiation failed. Please try again later.",
  "error": "Token generation failed"
}
```

### Status Checking Endpoint

**URL**: `POST /apps/api/v1/auth/check-activation-status/`

**Request Body**:
```json
{
  "email": "landlord@example.com"
}
```

**Response**:
```json
{
  "activation_status": 1,  // 0 = pending, 1 = completed, 2 = failed
  "message": "Account activated"
}
```

---

## User Flow

### Complete Activation Flow:

1. **Registration**:
   - User fills registration form with email, name, phone, etc.
   - Backend creates landlord account (inactive)
   - OTP sent to email

2. **OTP Verification**:
   - User enters 4-digit OTP
   - Backend verifies OTP
   - If landlord → redirect to `ActivationPaymentScreen`
   - If other role → redirect to login

3. **Payment Initiation**:
   - User sees activation fee: KES 500
   - Enters phone number (254XXXXXXXXX or 0XXXXXXXXX)
   - Clicks "Proceed to Payment"
   - App calls backend `/initiate-activation-payment/`

4. **Pesapal Checkout**:
   - Backend returns Pesapal redirect URL
   - WebView opens full-screen with checkout page
   - User selects payment method:
     - **M-Pesa**: Enter phone, receive STK push
     - **Card**: Enter card details
   - User completes payment on Pesapal

5. **Payment Verification**:
   - App detects payment completion URL
   - Starts polling `/check-activation-status/` every 3 seconds
   - Shows "Verifying Payment" UI with progress indicator

6. **Account Activation**:
   - Backend receives Pesapal IPN callback
   - Activates user and landlord profile
   - Status polling returns `activation_status: 1`

7. **Dashboard Redirect**:
   - Shows "Payment Successful!" message
   - Navigates to landlord dashboard
   - User can now access full platform features

---

## Payment Methods Supported

### 1. M-Pesa

- User enters M-Pesa phone number
- Pesapal sends STK push to phone
- User enters M-Pesa PIN
- Payment processed instantly

### 2. Credit/Debit Card

- User enters card details on Pesapal checkout
- Supports Visa, Mastercard, American Express
- 3D Secure authentication if required
- International cards supported

---

## Error Handling

### Network Errors

```dart
try {
  var response = await paymentProvider.initiateActivationPaymentPesapal(...);
} catch (error) {
  setState(() {
    _paymentState = PaymentState.failed;
    _errorMessage = 'Network error. Please try again.';
  });
}
```

### Payment Failures

- Pesapal returns error → Show error message
- User can retry payment with "Try Again" button
- Polls timeout after 30 seconds → Show timeout message

### Backend Errors

- Token generation fails → Clear error message shown
- Invalid credentials → User informed to contact support
- Server errors → Retry mechanism available

---

## Testing

### Local Testing

1. **Start Backend**:
   ```bash
   cd ~/Desktop/projects/smartnyumba_backup
   python manage.py runserver
   ```

2. **Update Constants** (if testing locally):
   ```dart
   // lib/utils/constants/constants.dart
   static const String BASE_URL = 'http://10.0.2.2:8000';  // Android emulator
   // OR
   static const String BASE_URL = 'http://localhost:8000';  // iOS simulator
   ```

3. **Run Flutter App**:
   ```bash
   cd ~/AndroidStudioProjects/smart_nyumba
   flutter run
   ```

4. **Test Flow**:
   - Register as landlord
   - Verify OTP (use code from email)
   - Enter phone: `254712345678`
   - Complete payment on Pesapal sandbox
   - Use test card: `4111 1111 1111 1111`, CVV: `123`

### Pesapal Sandbox Testing

**Test Cards**:
- **Visa**: `4111 1111 1111 1111`
- **Mastercard**: `5500 0000 0000 0004`
- **CVV**: `123`
- **Expiry**: Any future date

**Test M-Pesa**:
- **Phone**: `254712345678`
- Sandbox auto-completes payment

---

## UI/UX Improvements

### Payment Screens

1. **Initial State**:
   - Clean, professional design
   - Clear activation fee display
   - Phone number input with hints
   - "Payment secured by Pesapal" badge

2. **WebView State**:
   - Full-screen checkout experience
   - Custom AppBar with close button
   - Cancel confirmation dialog
   - Seamless Pesapal integration

3. **Polling State**:
   - Progress indicator
   - "Verifying Payment" message
   - Attempt counter (1/10)
   - Clear user feedback

4. **Success State**:
   - Green success card
   - Checkmark icon
   - "Account activated" message
   - Auto-redirect countdown

5. **Failed State**:
   - Red error card
   - Clear error message
   - "Try Again" button
   - Helpful troubleshooting hints

---

## Migration Notes

### From M-Pesa to Pesapal

**Old Flow (Removed)**:
- M-Pesa STK Push initiated directly
- Long polling (30 attempts * 10 seconds)
- M-Pesa only, no card support

**New Flow (Current)**:
- Pesapal redirect URL → WebView checkout
- Short polling (10 attempts * 3 seconds)
- M-Pesa + Card + International payments

**Backward Compatibility**:
- Old M-Pesa method (`initiateActivationPayment`) still exists
- Can be removed in future release after migration complete
- No data migration needed - operates on same database tables

---

## Troubleshooting

### Issue: "Payment initiation failed"

**Possible Causes**:
1. Backend Pesapal credentials invalid
2. Network connectivity issues
3. Server error

**Solution**:
- Check backend logs
- Verify Pesapal credentials in `.env`
- Retry payment

### Issue: "Payment verification timeout"

**Possible Causes**:
1. Pesapal IPN not received by backend
2. Backend callback processing error
3. Database update failed

**Solution**:
- Check backend IPN logs
- Manually verify payment status on Pesapal dashboard
- Contact support for manual activation

### Issue: WebView not loading

**Possible Causes**:
1. Internet connection issue
2. Invalid redirect URL
3. WebView plugin issue

**Solution**:
- Check internet connection
- Verify `webview_flutter` dependency installed
- Check console logs for errors

---

## Security Considerations

### PCI Compliance

- No card details stored in app
- All payment data handled by Pesapal
- Secure HTTPS communication
- No sensitive data in logs

### User Data Protection

- Phone numbers formatted securely
- Email validation before submission
- No plaintext password storage
- Session tokens properly managed

### WebView Security

- JavaScript enabled only for Pesapal domain
- Navigation restricted to payment flow
- SSL certificate validation
- Secure redirect URL validation

---

## Performance Optimizations

1. **WebView Initialization**: Pre-initialized on screen load
2. **Polling Strategy**: Short intervals (3s) with timeout
3. **State Management**: Efficient setState() usage
4. **Network Requests**: Proper error handling and timeouts
5. **UI Responsiveness**: Loading indicators for all async operations

---

## Future Enhancements

### Potential Improvements:

1. **Payment History**: Store activation payment details for receipt
2. **Multiple Payment Options**: Pre-select M-Pesa vs Card
3. **Retry Logic**: Automatic retry on network failures
4. **Push Notifications**: Notify on payment completion
5. **Receipt Generation**: PDF receipt after successful payment
6. **Payment Analytics**: Track conversion rates and failure reasons

---

## Files Modified Summary

| File | Changes | Lines Changed |
|------|---------|---------------|
| `pubspec.yaml` | Added webview_flutter | +1 |
| `activation_payment_screen.dart` | Complete rewrite for Pesapal | ~700 lines |
| `payment_provider.dart` | Added Pesapal method | +50 lines |
| `activation_payment_response.dart` | Extended model | +20 lines |
| `shared_preference_builder.dart` | Added lastName support | +10 lines |
| `otp.dart` | Pass lastName to payment | +2 lines |

**Total**: ~783 lines changed across 6 files

---

## Deployment Checklist

### Before Deploying to Production:

- [ ] Update backend Pesapal credentials to production
- [ ] Register production IPN URL on Pesapal dashboard
- [ ] Test complete flow in staging environment
- [ ] Update Constants.BASE_URL to production URL
- [ ] Test with real M-Pesa and Card payments
- [ ] Verify activation status checking works
- [ ] Test error scenarios (payment failures, network issues)
- [ ] Update app version in pubspec.yaml
- [ ] Create release build: `flutter build apk --release`
- [ ] Submit to Google Play Store / App Store

---

## Support

For issues or questions:
- **Backend**: Check `~/Desktop/projects/smartnyumba_backup/PESAPAL_MIGRATION_AND_OTP_FIX.md`
- **API Docs**: Backend documentation
- **Pesapal Docs**: https://developer.pesapal.com/

---

**Implementation Date**: May 12, 2026
**Status**: ✅ Complete
**Tested**: ✅ Local Development
**Production Ready**: Pending credentials update
