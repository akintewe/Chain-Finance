# Price Alerts Setup Guide

## Overview
The price alert system monitors cryptocurrency prices and automatically sends push notifications to all users when significant price changes occur (5% or more). It also allows sending custom announcements and market updates.

## OneSignal REST API Key Setup

### Step 1: Get Your OneSignal REST API Key
1. Go to your OneSignal dashboard: https://onesignal.com/
2. Select your app (nexa-prime)
3. Go to **Settings** → **Keys & IDs**
4. Copy the **REST API Key** (not the App ID)

### Step 2: Update the Code
Replace `YOUR_ONESIGNAL_REST_API_KEY` in `lib/services/price_alert_service.dart`:

```dart
static const String _oneSignalRestApiKey = "YOUR_ACTUAL_REST_API_KEY_HERE";
```

**⚠️ Security Note**: In production, store this key securely using environment variables or secure storage, not hardcoded in the app.

## Features

### 🔄 Automatic Price Monitoring
- Monitors 10 major cryptocurrencies: BTC, ETH, USDT, BNB, SOL, ADA, XRP, DOGE, MATIC, TRX
- Checks prices every 30 minutes
- Sends alerts when price changes ≥5%
- 1-hour cooldown between alerts for the same token
- Smart emoji indicators (📈 for increases, 📉 for decreases)

### 📢 Custom Announcements
- Send custom notifications to all users
- Market updates with additional data
- Accessible from Settings → Send Custom Announcement

### 🎛️ User Controls
- Toggle price monitoring on/off in Settings
- "Auto Price Monitoring" switch
- Real-time monitoring status

## How It Works

### 1. Price Monitoring Flow
```
App Launch → Start Price Monitoring → Check Prices Every 30min → 
Compare with Previous → Send Alert if ≥5% change → Update Previous Price
```

### 2. Notification Types
- **Price Alerts**: Automatic notifications for significant price changes
- **Custom Announcements**: Manual notifications from app admin
- **Market Updates**: Market-related notifications with additional data

### 3. Sample Notifications
```
📈 BTC Price Alert
Bitcoin has increased by 7.2% to $45,230.50

📉 ETH Price Alert  
Ethereum has decreased by 5.8% to $2,890.25

🔔 Market Update
New DeFi protocol launched on Ethereum network
```

## Configuration Options

### In `price_alert_service.dart`:

```dart
// Minimum percentage change to trigger alert
static const double _minPercentageChange = 5.0; // 5%

// Cooldown between alerts for same token
static const Duration _alertCooldown = Duration(hours: 1);

// Price check interval (in Timer.periodic)
Duration(minutes: 30) // Check every 30 minutes

// Tokens to monitor
static const List<String> _tokensToMonitor = [
  'BTC', 'ETH', 'USDT', 'BNB', 'SOL', 'ADA', 'XRP', 'DOGE', 'MATIC', 'TRX'
];
```

## Usage Examples

### Send Custom Announcement
```dart
await PriceAlertService.sendCustomAnnouncement(
  title: "🚀 New Feature Available",
  message: "Staking rewards are now live! Earn up to 12% APY on your crypto holdings.",
  type: "feature_announcement",
);
```

### Send Market Update
```dart
await PriceAlertService.sendMarketUpdate(
  title: "📊 Market Analysis",
  message: "Bitcoin breaks $50K resistance level with strong volume",
  marketData: {
    'symbol': 'BTC',
    'price': 50000,
    'volume': '2.5B',
    'change_24h': 8.5
  },
);
```

## Troubleshooting

### Common Issues:

1. **Notifications not sending**
   - Check OneSignal REST API key is correct
   - Verify app is connected to internet
   - Check OneSignal dashboard for delivery status

2. **Price monitoring not working**
   - Ensure CoinAPI key is valid in `price_service.dart`
   - Check network connectivity
   - Verify timer is running (check logs)

3. **Users not receiving notifications**
   - Ensure users have granted notification permissions
   - Check if users are subscribed to OneSignal
   - Verify OneSignal player IDs are being sent to backend

### Debug Logs:
Enable debug mode to see detailed logs:
```dart
if (kDebugMode) {
  print('Price monitoring logs will appear here');
}
```

## Security Considerations

1. **API Key Security**: Store OneSignal REST API key securely
2. **Rate Limiting**: Implement rate limiting for manual announcements
3. **User Permissions**: Respect user notification preferences
4. **Data Privacy**: Don't include sensitive user data in notifications

## Performance Notes

- Price monitoring runs in background
- Minimal battery impact (30-minute intervals)
- Efficient API usage with error handling
- Automatic cleanup on app termination

## Testing

### Test Price Alerts:
1. Temporarily reduce `_minPercentageChange` to 1%
2. Reduce `_alertCooldown` to 1 minute
3. Monitor logs for price changes
4. Verify notifications appear in OneSignal dashboard

### Test Custom Announcements:
1. Go to Settings → Send Custom Announcement
2. Enter title and message
3. Send notification
4. Check OneSignal dashboard for delivery status

## Next Steps

1. **Replace the REST API key** in the code
2. **Test the functionality** with a small percentage change
3. **Monitor OneSignal dashboard** for delivery statistics
4. **Customize notification content** as needed
5. **Add user preferences** for notification types (optional)

The system is now ready to automatically monitor prices and send notifications to all your users! 🚀 