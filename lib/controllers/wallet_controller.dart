import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controllers/auth_controller.dart';
import 'package:nexa_prime/services/price_service.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';

class WalletController extends GetxController {
  static WalletController get instance => Get.find();
  final AuthController _authController = Get.find();
  
  final _isLoading = false.obs;
  final _walletData = Rx<Map<String, dynamic>?>(null);
  final _tokens = <Map<String, dynamic>>[].obs;
  final RxMap<String, String> _networks = <String, String>{}.obs; // code -> display name
  final RxMap<String, dynamic> _allTokensByNetwork = <String, dynamic>{}.obs;
  final RxMap<String, double> _prices = <String, double>{}.obs;
  final RxMap<String, double> _priceChanges = <String, double>{}.obs;
  
  // Callback for price updates
  Function? _onPricesUpdated;
  final RxList<Map<String, dynamic>> cryptoList = <Map<String, dynamic>>[
    {
      'name': 'Bitcoin',
      'symbol': 'BTC',
      'icon': 'assets/icons/Cryptocurrency (2).png',
    },
    {
      'name': 'Ethereum',
      'symbol': 'ETH',
      'icon': 'assets/icons/Cryptocurrency (1).png',
    },
    {
      'name': 'Tether USD',
      'symbol': 'USDT',
      'icon': 'assets/icons/Cryptocurrency (3).png',
    },
    {
      'name': 'Tron',
      'symbol': 'TRX',
      'icon': 'assets/icons/Cryptocurrency.png',
    },
    {
      'name': 'BNB',
      'symbol': 'BNB',
      'icon': 'assets/icons/Cryptocurrency.png',
    },
    {
      'name': 'Solana',
      'symbol': 'SOL',
      'icon': 'assets/icons/Cryptocurrency.png',
    },
    {
      'name': 'XRP',
      'symbol': 'XRP',
      'icon': 'assets/icons/Cryptocurrency.png',
    },
    {
      'name': 'Cardano',
      'symbol': 'ADA',
      'icon': 'assets/icons/Cryptocurrency.png',
    },
    {
      'name': 'Dogecoin',
      'symbol': 'DOGE',
      'icon': 'assets/icons/Cryptocurrency.png',
    },
    {
      'name': 'Polygon',
      'symbol': 'MATIC',
      'icon': 'assets/icons/Cryptocurrency.png',
    }
  ].obs;
  
  final RxList<Map<String, dynamic>> favoritesList = <Map<String, dynamic>>[
    {
      'name': 'Bitcoin',
      'symbol': 'BTC',
      'icon': 'assets/icons/Cryptocurrency (2).png',
    },
    {
      'name': 'Ethereum',
      'symbol': 'ETH',
      'icon': 'assets/icons/Cryptocurrency (1).png',
    },
    {
      'name': 'Tether USD',
      'symbol': 'USDT',
      'icon': 'assets/icons/Cryptocurrency (3).png',
    },
    {
      'name': 'BNB',
      'symbol': 'BNB',
      'icon': 'assets/icons/Cryptocurrency.png',
    },
  ].obs;
  
  bool get isLoading => _isLoading.value;
  Map<String, dynamic>? get walletData => _walletData.value;
  List<Map<String, dynamic>> get tokens => _tokens;
  Map<String, double> get prices => _prices;
  Map<String, String> get networks => _networks;
  Map<String, dynamic> get allTokensByNetwork => _allTokensByNetwork;

  Future<void> fetchWalletDetails() async {
    try {
      // Check if user is authenticated
      if (_authController.token.isEmpty) {
        print('No authentication token found');
        Get.snackbar('Authentication Error', 'Please login to view wallet details');
        return;
      }
      
      _isLoading.value = true;
      
      if (kDebugMode) {
        print('Fetching wallet details...');
        print('Token: ${_authController.token}');
        print('API URL: http://173.212.228.47:8888/api/wallet');
      }
      
      final response = await http.get(
        Uri.parse('http://173.212.228.47:8888/api/wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.token}',
        },
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _walletData.value = data['data'];
        
        if (kDebugMode) {
          print('Wallet data received: ${_walletData.value}');
          print('Wallet data keys: ${_walletData.value?.keys.toList()}');
        }
        
        _updateTokensList();
        
        // Fetch market data after wallet data is loaded
        await fetchMarketData();
      } else if (response.statusCode == 401) {
        // Handle unauthorized error
        final errorMessage = 'Authentication failed. Please login again.';
        print('Authentication error: $errorMessage');
        Get.snackbar('Authentication Error', errorMessage);
        _authController.showSessionExpiredDialog();
        return;
      } else if (response.statusCode == 500) {
        // Handle 500 error - show session expired dialog
        final errorMessage = 'Server error. Please try again later.';
        print('Server error: $errorMessage');
        Get.snackbar('Server Error', errorMessage);
        return;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to fetch wallet details';
        print('API error: ${response.statusCode} - $errorMessage');
        Get.snackbar('API Error', errorMessage);
        return;
      }
    } catch (e) {
      String errorMessage = 'Unknown error occurred';
      
      if (e.toString().contains('SocketException')) {
        errorMessage = 'Network error: Could not connect to server. Please check your internet connection.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout: Server is taking too long to respond.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Data format error: Server response is invalid.';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }
      
      print('Wallet fetch error: $e');
      Get.snackbar('Wallet Error', errorMessage);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchSupportedNetworksAndTokens() async {
    try {
      final response = await http.get(
        Uri.parse('http://173.212.228.47:8888/api/getAllTokens'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Handle new API structure where networks is an array
        final networksArray = data['data']['networks'] as List<dynamic>? ?? [];
        final tokensData = Map<String, dynamic>.from(data['data']['tokens'] ?? {});
        
        // Create a map of network codes to display names
        final Map<String, String> mappedNetworks = {};
        for (String networkCode in networksArray) {
          // Map network codes to display names
          switch (networkCode) {
            case 'bsc':
              mappedNetworks[networkCode] = 'Binance Smart Chain';
              break;
            case 'eth':
              mappedNetworks[networkCode] = 'Ethereum';
              break;
            case 'btc':
              mappedNetworks[networkCode] = 'Bitcoin';
              break;
            case 'tron':
              mappedNetworks[networkCode] = 'Tron';
              break;
            case 'ton':
              mappedNetworks[networkCode] = 'Toncoin';
              break;
            default:
              mappedNetworks[networkCode] = networkCode.toUpperCase();
          }
        }
        
        _networks.assignAll(mappedNetworks);
        _allTokensByNetwork.assignAll(tokensData);
        
        print('Networks loaded: $_networks');
        print('Tokens loaded: ${_allTokensByNetwork.keys}');
      } else {
        // Non-fatal; keep UI responsive
        print('Failed to fetch supported networks: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching supported networks: $e');
    }
  }

  void _updateTokensList() {
    if (_walletData.value == null) return;

    final tokens = <Map<String, dynamic>>[];
    double totalCalculatedBalance = 0.0;
    
    _walletData.value!.forEach((key, value) {
      if (key.endsWith('_balance') && key != 'total_balance') {
        final symbol = key.replaceAll('_balance', '').toUpperCase();
        final balance = double.tryParse(value.toString()) ?? 0.0;
        totalCalculatedBalance += balance;
        
        tokens.add({
          'name': _getTokenName(symbol),
          'icon': 'assets/icons/Cryptocurrency.png',
          'symbol': symbol,
          'balance': value.toString(),
        });
        
        if (kDebugMode) {
          print('Token: $symbol, Balance: $value, Running Total: $totalCalculatedBalance');
        }
      }
    });

    _tokens.value = tokens;
    
    if (kDebugMode) {
      print('Total calculated balance: $totalCalculatedBalance');
      print('Tokens found: ${tokens.length}');
      print('Wallet data keys: ${_walletData.value!.keys.toList()}');
    }
  }

  String _getTokenName(String symbol) {
    final names = {
      'BTC': 'Bitcoin',
      'ETH': 'Ethereum',
      'TRX': 'Tron',
      'USDT': 'Tether USD',
      'BNB': 'BNB',
      'SOL': 'Solana',
      'XRP': 'XRP',
      'ADA': 'Cardano',
      'DOGE': 'Dogecoin',
      'MATIC': 'Polygon',
      'BUSD': 'Binance USD',
      'CAKE': 'PancakeSwap',
      'DOT': 'Polkadot',
      'LINK': 'Chainlink',
      'LTC': 'Litecoin',
      'UNI': 'Uniswap',
      'SHIB': 'Shiba Inu',
      'AXS': 'Axie Infinity',
      'SXP': 'SXP',
      'MANA': 'Decentraland',
      'SAND': 'The Sandbox',
      'FTM': 'Fantom',
      'ATOM': 'Cosmos',
      'AVAX': 'Avalanche',
      'LUNA': 'Terra',
      'NEAR': 'NEAR Protocol',
      'BAKE': 'BakeryToken',
      'XVS': 'Venus',
      'TWT': 'Trust Wallet Token',
      'ALPACA': 'Alpaca Finance',
      'BELT': 'Belt Finance',
      'AUTO': 'AutoFarm',
      'NULS': 'NULS',
      'BNBX': 'BNBX',
      'DAI': 'Dai',
      'FIL': 'Filecoin',
      'BAT': 'Basic Attention Token',
      'CTSI': 'Cartesi',
      'REEF': 'Reef Finance',
      'ALICE': 'My Neighbor Alice',
      'HERO': 'Step Hero',
      'DAR': 'Mines of Dalarnia',
      'CHR': 'Chromia',
      'GALA': 'Gala',
      'ENJ': 'Enjin Coin',
      'LOKA': 'League of Kingdoms',
      'MOVR': 'Moonriver',
      'BAND': 'Band Protocol',
      'PERP': 'Perpetual Protocol',
      'COTI': 'COTI',
      'OCEAN': 'Ocean Protocol',
      'RUNE': 'THORChain',
      'ZIL': 'Zilliqa',
      'HBAR': 'Hedera',
      'ONT': 'Ontology',
      'ONE': 'Harmony',
      'CTK': 'CertiK',
      'THETA': 'Theta Network',
      'VET': 'VeChain',
      'NKN': 'NKN'
    };
    return names[symbol] ?? symbol;
  }

  String getBalanceForToken(String symbol) {
    if (_walletData.value == null) return '0.00000000';
    final balanceKey = '${symbol.toLowerCase()}_balance';
    return _walletData.value?[balanceKey]?.toString() ?? '0.00000000';
  }

  String getTotalBalance() {
    if (_walletData.value == null) return '0.00';
    
    // Calculate total balance by summing all token balances
    double totalBalance = 0.0;
    
    _walletData.value!.forEach((key, value) {
      if (key.endsWith('_balance') && key != 'total_balance') {
        try {
          final balance = double.tryParse(value.toString()) ?? 0.0;
          totalBalance += balance;
        } catch (e) {
          print('Error parsing balance for $key: $value');
        }
      }
    });
    
    return totalBalance.toStringAsFixed(2);
  }
  
  // Get total balance in USD by converting each token balance
  String getTotalBalanceUSD() {
    if (_walletData.value == null) return '\$0.00';
    
    double totalBalanceUSD = 0.0;
    
    _walletData.value!.forEach((key, value) {
      if (key.endsWith('_balance') && key != 'total_balance') {
        try {
          final symbol = key.replaceAll('_balance', '').toUpperCase();
          final balance = double.tryParse(value.toString()) ?? 0.0;
          
          // Get current price for this token
          final price = _prices[symbol] ?? 0.0;
          final balanceUSD = balance * price;
          totalBalanceUSD += balanceUSD;
          
          if (kDebugMode) {
            print('$symbol: $balance × \$${price.toStringAsFixed(2)} = \$${balanceUSD.toStringAsFixed(2)}');
          }
        } catch (e) {
          print('Error calculating USD balance for $key: $value');
        }
      }
    });
    
    return '\$${totalBalanceUSD.toStringAsFixed(2)}';
  }
  
  // Get total balance in a specific currency (e.g., USDT, BTC, etc.)
  String getTotalBalanceInCurrency(String currency) {
    if (_walletData.value == null) return '0.00';
    
    double totalBalance = 0.0;
    
    _walletData.value!.forEach((key, value) {
      if (key.endsWith('_balance') && key != 'total_balance') {
        try {
          final balance = double.tryParse(value.toString()) ?? 0.0;
          
          // If the currency matches the token, add directly
          if (key == '${currency.toLowerCase()}_balance') {
            totalBalance += balance;
          } else {
            // For other tokens, you might want to convert them
            // This is a simplified version - you could add conversion logic here
            totalBalance += balance;
          }
        } catch (e) {
          print('Error calculating balance for $key: $value');
        }
      }
    });
    
    return totalBalance.toStringAsFixed(8); // Use 8 decimal places for crypto
  }
  
  // Debug method to print all balances
  void printAllBalances() {
    if (_walletData.value == null) {
      print('No wallet data available');
      return;
    }
    
    print('=== WALLET BALANCE SUMMARY ===');
    double total = 0.0;
    
    _walletData.value!.forEach((key, value) {
      if (key.endsWith('_balance') && key != 'total_balance') {
        final symbol = key.replaceAll('_balance', '').toUpperCase();
        final balance = double.tryParse(value.toString()) ?? 0.0;
        total += balance;
        print('$symbol: $balance');
      }
    });
    
    print('Total Balance: $total');
    print('==============================');
  }
  
  // Force refresh wallet data and recalculate balances
  Future<void> refreshWalletData() async {
    await fetchWalletDetails();
    printAllBalances(); // Debug output
  }
  
  // Refresh only market data
  Future<void> refreshMarketData() async {
    await fetchMarketData();
    if (kDebugMode) {
      print('Market data refreshed');
    }
  }
  
  // Get a list of all token balances with their symbols
  List<Map<String, dynamic>> getAllTokenBalances() {
    if (_walletData.value == null) return [];
    
    final balances = <Map<String, dynamic>>[];
    
    _walletData.value!.forEach((key, value) {
      if (key.endsWith('_balance') && key != 'total_balance') {
        final symbol = key.replaceAll('_balance', '').toUpperCase();
        final balance = double.tryParse(value.toString()) ?? 0.0;
        
        balances.add({
          'symbol': symbol,
          'balance': balance,
          'balanceString': value.toString(),
          'name': _getTokenName(symbol),
        });
      }
    });
    
    return balances;
  }
  
  // Check if wallet has any tokens with non-zero balance
  bool hasAnyBalance() {
    if (_walletData.value == null) return false;
    
    return _walletData.value!.entries.any((entry) {
      if (entry.key.endsWith('_balance') && entry.key != 'total_balance') {
        final balance = double.tryParse(entry.value.toString()) ?? 0.0;
        return balance > 0;
      }
      return false;
    });
  }
  
  // Market data for portfolio overview
  final RxMap<String, Map<String, dynamic>> _marketData = <String, Map<String, dynamic>>{}.obs;
  
  // Get market data for a specific token
  Map<String, dynamic>? getMarketData(String symbol) {
    return _marketData[symbol];
  }
  
  // Get portfolio 24h change percentage
  String getPortfolio24hChange() {
    if (_walletData.value == null || _marketData.isEmpty) return '+0.00%';
    
    double totalValue = 0.0;
    double totalChange = 0.0;
    
    _walletData.value!.forEach((key, value) {
      if (key.endsWith('_balance') && key != 'total_balance') {
        final symbol = key.replaceAll('_balance', '').toUpperCase();
        final balance = double.tryParse(value.toString()) ?? 0.0;
        final marketData = _marketData[symbol];
        
        if (marketData != null) {
          final price = marketData['price'] ?? 0.0;
          final change24h = marketData['change_24h'] ?? 0.0;
          
          final tokenValue = balance * price;
          totalValue += tokenValue;
          totalChange += tokenValue * (change24h / 100);
        }
      }
    });
    
    if (totalValue == 0) return '+0.00%';
    final changePercentage = (totalChange / totalValue) * 100;
    
    if (changePercentage >= 0) {
      return '+${changePercentage.toStringAsFixed(2)}%';
    } else {
      return '${changePercentage.toStringAsFixed(2)}%';
    }
  }
  
  // Get portfolio 24h high
  String getPortfolio24hHigh() {
    if (_walletData.value == null || _marketData.isEmpty) return '\$0.00';
    
    double totalHigh = 0.0;
    
    _walletData.value!.forEach((key, value) {
      if (key.endsWith('_balance') && key != 'total_balance') {
        final symbol = key.replaceAll('_balance', '').toUpperCase();
        final balance = double.tryParse(value.toString()) ?? 0.0;
        final marketData = _marketData[symbol];
        
        if (marketData != null) {
          final high24h = marketData['high_24h'] ?? 0.0;
          totalHigh += balance * high24h;
        }
      }
    });
    
    return '\$${totalHigh.toStringAsFixed(2)}';
  }
  
  // Get portfolio 24h low
  String getPortfolio24hLow() {
    if (_walletData.value == null || _marketData.isEmpty) return '\$0.00';
    
    double totalLow = 0.0;
    
    _walletData.value!.forEach((key, value) {
      if (key.endsWith('_balance') && key != 'total_balance') {
        final symbol = key.replaceAll('_balance', '').toUpperCase();
        final marketData = _marketData[symbol];
        
        if (marketData != null) {
          final low24h = marketData['low_24h'] ?? 0.0;
          final balance = double.tryParse(value.toString()) ?? 0.0;
          totalLow += balance * low24h;
        }
      }
    });
    
    return '\$${totalLow.toStringAsFixed(2)}';
  }
  
  // Get color for 24h change (green for positive, red for negative)
  Color getPortfolio24hChangeColor() {
    final change = getPortfolio24hChange();
    if (change.startsWith('+')) {
      return Colors.green;
    } else if (change.startsWith('-')) {
      return Colors.red;
    }
    return AppColors.text;
  }
  
  // Fetch market data for all tokens in wallet
  Future<void> fetchMarketData() async {
    try {
      if (_walletData.value == null) return;
      
      final tokens = <String>[];
      _walletData.value!.forEach((key, value) {
        if (key.endsWith('_balance') && key != 'total_balance') {
          final symbol = key.replaceAll('_balance', '').toUpperCase();
          tokens.add(symbol);
        }
      });
      
      if (tokens.isEmpty) return;
      
      // Fetch market data for each token
      for (final symbol in tokens) {
        await _fetchTokenMarketData(symbol);
      }
      
      if (kDebugMode) {
        print('Market data fetched for ${tokens.length} tokens');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching market data: $e');
      }
    }
  }
  
  // Fetch market data for a specific token
  Future<void> _fetchTokenMarketData(String symbol) async {
    try {
      // You can use CoinGecko API or any other crypto market data API
      // For now, I'll create mock data structure that you can replace with real API calls
      
      // Example API endpoint: https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd&include_24hr_change=true&include_24hr_high=true&include_24hr_low=true
      
      // Mock data for demonstration - replace with real API call
      final mockData = _generateMockMarketData(symbol);
      _marketData[symbol] = mockData;
      
      if (kDebugMode) {
        print('Market data for $symbol: $mockData');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching market data for $symbol: $e');
      }
    }
  }
  
  // Generate mock market data (replace with real API data)
  Map<String, dynamic> _generateMockMarketData(String symbol) {
    // This is mock data - replace with real API calls
    final random = Random();
    
    return {
      'price': 1000 + random.nextDouble() * 50000, // Random price between 1000-51000
      'change_24h': -10 + random.nextDouble() * 20, // Random change between -10% to +10%
      'high_24h': 1000 + random.nextDouble() * 60000, // Random high
      'low_24h': 500 + random.nextDouble() * 40000, // Random low
      'volume_24h': 1000000 + random.nextDouble() * 10000000, // Random volume
      'market_cap': 1000000000 + random.nextDouble() * 10000000000, // Random market cap
    };
  }
  
  // Format total balance for display (with proper decimal places)
  String getFormattedTotalBalance() {
    final total = getTotalBalance();
    final doubleValue = double.tryParse(total) ?? 0.0;
    
    if (doubleValue == 0.0) return '0.00';
    if (doubleValue < 0.01) return doubleValue.toStringAsFixed(8);
    if (doubleValue < 1.0) return doubleValue.toStringAsFixed(4);
    if (doubleValue < 100.0) return doubleValue.toStringAsFixed(2);
    return doubleValue.toStringAsFixed(2);
  }

  String get walletAddress => _walletData.value?['address'] ?? '';

  Map<String, dynamic> get userData => _walletData.value ?? {};
  String get userEmail => userData['email'] ?? '';
  String get userName => userData['name'] ?? '';

  String get privateKey => _walletData.value?['private_key'] ?? '';

  // Reset wallet controller state
  void resetState() {
    _isLoading.value = false;
    _walletData.value = null;
    _tokens.clear();
    _prices.clear();
    _priceChanges.clear();
    print('Wallet controller state reset');
  }

  Future<Map<String, dynamic>?> getUserByUUID(String uuid) async {
    try {
      final response = await http.get(
        Uri.parse('http://173.212.228.47:8888/api/users/$uuid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.token}',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        final data = jsonDecode(response.body);
        return data['data'];
      }
      else {
        print(response.body);
        return null;
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      return null;
    }
  }

  Future<void> sendInternal(Map<String, dynamic> data) async {
    try {
      // Prepare payload according to API specification
      final payload = {
        'receiver_uuid': data['receiver_uuid'],
        'amount': data['amount'],
        'currency': data['currency'],
        'note': data['note'] ?? '',
      };

      final response = await http.post(
        Uri.parse('http://173.212.228.47:8888/api/transaction/internal'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.token}',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Internal transaction successful: ${response.body}');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw errorData['message'] ?? 'Invalid input or insufficient balance';
      } else if (response.statusCode == 500) {
        throw 'Transaction failed - server error';
      } else {
        throw 'Failed to send transaction: ${response.statusCode}';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendExternal(Map<String, dynamic> data) async {
    try {
      // Prepare payload according to API specification
      final payload = {
        'to_address': data['to_address'],
        'amount': data['amount'],
      };

      final response = await http.post(
        Uri.parse('http://173.212.228.47:8888/api/transaction/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.token}',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('External transaction successful: ${response.body}');
      } else if (response.statusCode == 500) {
        throw 'Failed to send crypto - server error';
      } else {
        throw 'Failed to send crypto: ${response.statusCode}';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePrices() async {
    try {
      _isLoading.value = true;
      // Fetch USD rates for all assets
      final data = await PriceService.getAllRates('USD');
      
      if (data['rates'] != null) {
        for (var rate in data['rates']) {
          final symbol = rate['asset_id_quote'];
          final price = rate['rate'].toDouble();
          
          // Only update prices for our tracked cryptocurrencies
          if (cryptoList.any((crypto) => crypto['symbol'] == symbol)) {
            _prices[symbol] = 1 / price; // Invert rate since we got USD/CRYPTO
            
            // Simulate price change (in a real app, you'd compare with historical data)
            _priceChanges[symbol] = (Random().nextDouble() * 5) * (Random().nextBool() ? 1 : -1);
          }
        }
        
        // USDT is pegged to USD
        _prices['USDT'] = 1.0;
        _priceChanges['USDT'] = 0.0;
        
        // Notify that prices have been updated
        _notifyPriceUpdate();
      }
    } catch (e) {
      print('Error updating prices: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Method to notify when prices are updated
  void _notifyPriceUpdate() {
    // This will trigger any listeners or can be called by the wallet screen
    print('Prices updated, notifying listeners...');
    if (_onPricesUpdated != null) {
      _onPricesUpdated!();
    }
  }

  // Method to set price update callback
  void setPriceUpdateCallback(Function callback) {
    _onPricesUpdated = callback;
  }

  // Method to refresh pie chart (can be called from wallet screen)
  void refreshPieChart() {
    // This will be called by the wallet screen when prices are updated
    print('Refreshing pie chart...');
  }

  double getPriceForToken(String symbol) => _prices[symbol] ?? 0.0;
  double getPriceChangeForToken(String symbol) => _priceChanges[symbol] ?? 0.0;

  bool isFavorite(String symbol) => 
      favoritesList.any((token) => token['symbol'] == symbol);

  void toggleFavorite(Map<String, dynamic> token) {
    if (isFavorite(token['symbol'])) {
      favoritesList.removeWhere((t) => t['symbol'] == token['symbol']);
    } else {
      favoritesList.add(token);
    }
  }

  double get totalPortfolioValue {
    double total = 0;
    for (var token in tokens) {
      final balance = double.tryParse(token['balance'].toString()) ?? 0;
      final price = double.tryParse(token['price'].toString()) ?? 0;
      total += balance * price;
    }
    return total;
  }

  @override
  void onInit() {
    super.onInit();
    updatePrices();
    // Preload networks and tokens listing
    fetchSupportedNetworksAndTokens();
    // Update prices every 3 minutes
    Timer.periodic(const Duration(minutes: 3), (_) {
      print('Updating prices...');
      updatePrices();
    });
  }
} 