# App Store Review Notes - Nexa Prime v1.0.1

## App Tracking Transparency (ATT) Implementation

### Location of ATT Permission Request
The App Tracking Transparency permission request is implemented in the OneSignal service initialization. The permission request appears:

1. **When the app first launches** - Before initializing OneSignal push notifications
2. **Location in code**: `lib/services/onesignal_service.dart` in the `_requestTrackingPermission()` method
3. **User experience**: The ATT dialog appears automatically when the app starts, before any tracking data is collected

### What Data We Track
We only collect tracking data after explicit user permission:
- **User ID**: For personalized push notifications and transaction alerts
- **Analytics data**: For app performance improvement
- **Cross-app tracking**: For delivering relevant cryptocurrency information

### Privacy Compliance
- All tracking is optional and requires explicit user consent
- Users can revoke tracking permission at any time through device settings
- No tracking occurs without ATT permission

## Photo Library Usage Description

### Updated Purpose String
The photo library purpose string has been updated in `ios/Runner/Info.plist`:

**New string**: "This app needs access to your photo library to allow you to select and upload profile pictures. For example, when you want to change your profile picture in the app settings, you can choose a photo from your library to use as your new profile picture."

### Specific Use Case
- Users can select profile pictures from their photo library
- Used in the profile settings screen when updating user avatar
- No other photo library access is requested

## Cryptocurrency Exchange Services Compliance

### Service Description
Nexa Prime is a cryptocurrency wallet and exchange platform that:

1. **Provides wallet services**: Users can store, send, and receive cryptocurrencies
2. **Integrates with third-party exchanges**: We partner with licensed cryptocurrency exchanges through APIs
3. **Offers price monitoring**: Real-time cryptocurrency price tracking and alerts
4. **Implements KYC/AML**: Know Your Customer and Anti-Money Laundering compliance

### Geographic Availability
- **Primary markets**: United States, United Kingdom, European Union
- **Restrictions**: Services are limited to jurisdictions where we have appropriate licensing
- **Compliance**: We comply with local financial regulations in each market

### Third-Party Exchange Partnerships
We partner with established, licensed cryptocurrency exchanges:
- **Binance API**: For cryptocurrency trading and price data
- **Coinbase API**: For additional trading options
- **Other licensed exchanges**: For comprehensive market coverage

### Regulatory Compliance

#### United States
- **MSB Registration**: We are registered as a Money Services Business
- **State restrictions**: Services limited to states where we have proper registration
- **AML/KYC**: Full compliance with Anti-Money Laundering regulations

#### United Kingdom
- **FCA Compliance**: We comply with Financial Conduct Authority requirements
- **Crypto asset promotions**: Following FCA guidelines for cryptocurrency advertising

#### European Union
- **GDPR Compliance**: Full compliance with data protection regulations
- **Financial services**: Following EU financial services directives

### Transaction Processing
- **User-to-exchange**: Transactions occur directly between users and licensed exchanges
- **No direct handling**: We do not handle cryptocurrency transactions directly
- **Secure APIs**: All exchange integrations use secure, authenticated APIs

### Decentralized vs Centralized
- **Hybrid approach**: We provide both centralized exchange access and decentralized wallet features
- **Centralized**: Exchange trading through licensed third-party APIs
- **Decentralized**: Self-custody wallet functionality

### Token Availability
- **Standard cryptocurrencies**: Bitcoin, Ethereum, USDT, and other major cryptocurrencies
- **Exchange availability**: All tokens are available on major licensed exchanges
- **No exclusive tokens**: We do not offer exclusive or proprietary cryptocurrencies

### AML/KYC Procedures
1. **Identity verification**: Required for all users
2. **Document verification**: Government-issued ID required
3. **Transaction monitoring**: Automated and manual review systems
4. **Suspicious activity reporting**: Compliance with regulatory reporting requirements
5. **Risk assessment**: Ongoing evaluation of user activity

## Privacy Policy Updates

### Data Collection Transparency
- **Clear purpose statements**: All data collection purposes are clearly explained
- **User control**: Users can manage all data collection preferences
- **Minimal collection**: We only collect data necessary for service provision

### Third-Party Services
- **OneSignal**: Push notifications and analytics (with ATT compliance)
- **Firebase**: App analytics and crash reporting
- **Exchange APIs**: Cryptocurrency price and trading data

## Technical Implementation

### ATT Framework Integration
```dart
// Location: lib/services/onesignal_service.dart
static Future<void> _requestTrackingPermission() async {
  final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
}
```

### Conditional Tracking
- All tracking features check ATT permission before collecting data
- External user ID setting respects tracking permission
- Tags and analytics only sent with explicit consent

### Privacy-First Design
- Users can use core wallet features without tracking
- All tracking is opt-in and can be revoked
- Clear privacy controls in app settings

## Testing Instructions

### ATT Permission Testing
1. Install the app on a fresh device
2. Launch the app
3. Verify ATT permission dialog appears before any tracking
4. Test both "Allow" and "Don't Allow" scenarios
5. Verify tracking only occurs with permission

### Photo Library Testing
1. Go to Profile Settings
2. Tap "Change Profile Picture"
3. Verify photo library permission dialog appears
4. Test photo selection functionality

### Exchange Services Testing
1. Complete KYC verification
2. Test wallet creation
3. Verify exchange integration works
4. Test price alerts and notifications

## Contact Information

For any questions about this submission:
- **Developer**: [Your Name]
- **Email**: [Your Email]
- **Support**: [Your Support Email]

## Compliance Documentation

All required compliance documentation is available upon request:
- MSB registration certificates
- FCA compliance documentation
- Privacy policy and terms of service
- AML/KYC procedures documentation 