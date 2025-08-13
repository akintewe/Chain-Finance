import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controllers/auth_controller.dart';
import 'package:nexa_prime/services/price_service.dart';
import 'dart:async';
import 'dart:math';

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
      _isLoading.value = true;
      
      final response = await http.get(
        Uri.parse('https://chdevapi.com.ng/api/wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _walletData.value = data['data'];
        _updateTokensList();
      } else if (response.statusCode == 500) {
        // Handle 500 error - show session expired dialog
        print('Session expired - showing session expired dialog');
        _authController.showSessionExpiredDialog();
        return;
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Failed to fetch wallet details';
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchSupportedNetworksAndTokens() async {
    try {
      final response = await http.get(
        Uri.parse('https://chdevapi.com.ng/api/getAllTokens'),
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
    _walletData.value!.forEach((key, value) {
      if (key.endsWith('_balance') && key != 'total_balance') {
        final symbol = key.replaceAll('_balance', '').toUpperCase();
        tokens.add({
          'name': _getTokenName(symbol),
          'symbol': symbol,
          'icon': 'assets/icons/Cryptocurrency.png',
          'balance': value.toString(),
        });
      }
    });

    _tokens.value = tokens;
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
      'ADA': 'Cardano',
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
    final balance = _walletData.value?['total_balance'] ?? 0.0;
    if (balance is String) {
      return double.parse(balance).toStringAsFixed(2);
    }
    return (balance as num).toStringAsFixed(2);
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
        Uri.parse('https://chdevapi.com.ng/api/users/$uuid'),
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
        Uri.parse('https://chdevapi.com.ng/api/transaction/internal'),
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
        Uri.parse('https://chdevapi.com.ng/api/transaction/send'),
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