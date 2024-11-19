import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controllers/auth_controller.dart';

class WalletController extends GetxController {
  static WalletController get instance => Get.find();
  final AuthController _authController = Get.find();
  
  final _isLoading = false.obs;
  final _walletData = Rx<Map<String, dynamic>?>(null);
  final _tokens = <Map<String, dynamic>>[].obs;
  
  bool get isLoading => _isLoading.value;
  Map<String, dynamic>? get walletData => _walletData.value;
  List<Map<String, dynamic>> get tokens => _tokens;

  Future<void> fetchWalletDetails() async {
    try {
      _isLoading.value = true;
      
      final response = await http.get(
        Uri.parse('https://chainfinance.com.ng/api/wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authController.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _walletData.value = data['data'];
        _updateTokensList();
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Failed to fetch wallet details';
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      _isLoading.value = false;
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
    return symbol.toUpperCase();
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
} 