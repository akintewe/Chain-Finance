import 'package:get/get.dart';

class DashboardController extends GetxController {
  final _currentIndex = 0.obs;
  
  int get currentIndex => _currentIndex.value;
  
  void updateIndex(int index) {
    _currentIndex.value = index;
  }
  
  void goToWallet() {
    _currentIndex.value = 0;
  }
  
  void goToSwap() {
    _currentIndex.value = 1;
  }
  
  void goToTransactions() {
    _currentIndex.value = 2;
  }
  
  void goToSettings() {
    _currentIndex.value = 3;
  }
} 