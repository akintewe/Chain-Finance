import 'package:get/get.dart';
import 'package:nexa_prime/models/virtual_card.dart';
import 'package:nexa_prime/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VirtualAccountController extends GetxController {
  final RxList<VirtualCard> _cards = <VirtualCard>[].obs;
  final Rx<VirtualAccount?> _virtualAccount = Rx<VirtualAccount?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final Rx<CardDesign?> _selectedDesign = Rx<CardDesign?>(null);

  // Getters
  List<VirtualCard> get cards => _cards;
  VirtualAccount? get virtualAccount => _virtualAccount.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  CardDesign? get selectedDesign => _selectedDesign.value;

  // Available card designs
  final List<CardDesign> availableDesigns = [
    CardDesign(
      id: 'premium_blue',
      name: 'Premium Blue',
      primaryColor: '#1E3A8A',
      secondaryColor: '#3B82F6',
      gradientStart: '#1E3A8A',
      gradientEnd: '#3B82F6',
      pattern: 'geometric',
      logoPosition: 'top-right',
      hasGlow: true,
      texture: 'none',
    ),
    CardDesign(
      id: 'elegant_gold',
      name: 'Elegant Gold',
      primaryColor: '#B8860B',
      secondaryColor: '#FFD700',
      gradientStart: '#B8860B',
      gradientEnd: '#FFD700',
      pattern: 'luxury',
      logoPosition: 'top-left',
      hasGlow: true,
      texture: 'metallic',
    ),
    CardDesign(
      id: 'modern_black',
      name: 'Modern Black',
      primaryColor: '#000000',
      secondaryColor: '#333333',
      gradientStart: '#000000',
      gradientEnd: '#333333',
      pattern: 'minimal',
      logoPosition: 'top-right',
      hasGlow: false,
      texture: 'matte',
    ),
    CardDesign(
      id: 'vibrant_purple',
      name: 'Vibrant Purple',
      primaryColor: '#6B46C1',
      secondaryColor: '#A855F7',
      gradientStart: '#6B46C1',
      gradientEnd: '#A855F7',
      pattern: 'wave',
      logoPosition: 'top-left',
      hasGlow: true,
      texture: 'none',
    ),
    CardDesign(
      id: 'ocean_teal',
      name: 'Ocean Teal',
      primaryColor: '#0F766E',
      secondaryColor: '#14B8A6',
      gradientStart: '#0F766E',
      gradientEnd: '#14B8A6',
      pattern: 'flow',
      logoPosition: 'top-right',
      hasGlow: false,
      texture: 'none',
    ),
    CardDesign(
      id: 'sunset_orange',
      name: 'Sunset Orange',
      primaryColor: '#EA580C',
      secondaryColor: '#FB923C',
      gradientStart: '#EA580C',
      gradientEnd: '#FB923C',
      pattern: 'gradient',
      logoPosition: 'top-left',
      hasGlow: true,
      texture: 'none',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    // Delay initialization to ensure auth is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      loadVirtualAccount();
      loadCards();
    });
  }

  Future<void> loadVirtualAccount() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null || token.isEmpty) {
        print('No authentication token found, skipping virtual account load');
        return;
      }

      final response = await ApiService.getVirtualAccount(token);
      
      if (response != null && response['success'] == true) {
        _virtualAccount.value = VirtualAccount.fromJson(response['data']);
      } else {
        // Create virtual account if it doesn't exist
        await createVirtualAccount();
      }
    } catch (e) {
      _error.value = 'Failed to load virtual account: ${e.toString()}';
      print('Error loading virtual account: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createVirtualAccount() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userData = prefs.getString('user');
      
      if (token == null || userData == null) {
        throw Exception('No authentication data found');
      }

      final user = jsonDecode(userData);
      final accountName = '${user['firstName']} ${user['lastName']}';

      final response = await ApiService.createVirtualAccount(token, accountName);
      
      if (response != null && response['success'] == true) {
        _virtualAccount.value = VirtualAccount.fromJson(response['data']);
        Get.snackbar('Success', 'Virtual account created successfully!');
      } else {
        throw Exception('Failed to create virtual account');
      }
    } catch (e) {
      _error.value = 'Failed to create virtual account: ${e.toString()}';
      print('Error creating virtual account: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadCards() async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null || token.isEmpty) {
        print('No authentication token found, skipping cards load');
        return;
      }

      final response = await ApiService.getVirtualCards(token);
      
      if (response != null && response['success'] == true) {
        final cardsData = response['data'] as List<dynamic>;
        _cards.value = cardsData.map((card) => VirtualCard.fromJson(card)).toList();
      }
    } catch (e) {
      _error.value = 'Failed to load cards: ${e.toString()}';
      print('Error loading cards: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createCard(CardDesign design) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await ApiService.createVirtualCard(token, design);
      
      if (response != null && response['success'] == true) {
        final newCard = VirtualCard.fromJson(response['data']);
        _cards.add(newCard);
        Get.snackbar('Success', 'Virtual card created successfully!');
      } else {
        throw Exception('Failed to create virtual card');
      }
    } catch (e) {
      _error.value = 'Failed to create card: ${e.toString()}';
      print('Error creating card: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fundVirtualAccount(double amount) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await ApiService.fundVirtualAccount(token, amount);
      
      if (response != null && response['success'] == true) {
        // Update virtual account balance
        if (_virtualAccount.value != null) {
          final updatedAccount = VirtualAccount(
            id: _virtualAccount.value!.id,
            accountNumber: _virtualAccount.value!.accountNumber,
            bankName: _virtualAccount.value!.bankName,
            accountName: _virtualAccount.value!.accountName,
            currency: _virtualAccount.value!.currency,
            balance: _virtualAccount.value!.balance + amount,
            isActive: _virtualAccount.value!.isActive,
            createdAt: _virtualAccount.value!.createdAt,
            cards: _virtualAccount.value!.cards,
          );
          _virtualAccount.value = updatedAccount;
        }
        Get.snackbar('Success', 'Account funded successfully!');
      } else {
        throw Exception('Failed to fund account');
      }
    } catch (e) {
      _error.value = 'Failed to fund account: ${e.toString()}';
      print('Error funding account: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void selectDesign(CardDesign design) {
    _selectedDesign.value = design;
  }

  void clearError() {
    _error.value = '';
  }
}
