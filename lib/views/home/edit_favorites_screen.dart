import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/controllers/wallet_controller.dart';

class EditFavoritesScreen extends StatefulWidget {
  const EditFavoritesScreen({Key? key}) : super(key: key);

  @override
  State<EditFavoritesScreen> createState() => _EditFavoritesScreenState();
}

class _EditFavoritesScreenState extends State<EditFavoritesScreen> with SingleTickerProviderStateMixin {
  final WalletController walletController = Get.find();
  final List<Map<String, dynamic>> selectedTokens = [];
  final List<Map<String, dynamic>> availableTokens = [];
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    selectedTokens.addAll(walletController.favoritesList);
    availableTokens.addAll(
      walletController.cryptoList.where(
        (token) => !walletController.isFavorite(token['symbol'])
      ).toList()
    );
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = selectedTokens.removeAt(oldIndex);
      selectedTokens.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Favorites', style: AppTextStyles.heading2),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
            onPressed: () {
              walletController.favoritesList.clear();
              walletController.favoritesList.addAll(selectedTokens);
              Get.back();
            },
              child: Text(
                'Save',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.drag_indicator,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
            child: Text(
              'Drag to reorder favorites',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              onReorder: _onReorder,
              itemCount: selectedTokens.length,
              itemBuilder: (context, index) {
                final token = selectedTokens[index];
                return Dismissible(
                  key: Key(token['symbol']),
                  background: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade300,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    setState(() {
                      availableTokens.add(token);
                      selectedTokens.removeAt(index);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          token['icon'],
                          width: 24,
                          height: 24,
                        ),
                      ),
                      title: Text(
                        token['name'],
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        token['symbol'],
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        child: const Icon(
                          Icons.drag_handle,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (availableTokens.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                'Available Tokens',
                style: AppTextStyles.heading2.copyWith(fontSize: 18),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: availableTokens.length,
                itemBuilder: (context, index) {
                  final token = availableTokens[index];
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                token['icon'],
                                width: 24,
                                height: 24,
                              ),
                            ),
                            title: Text(
                              token['name'],
                              style: AppTextStyles.body2.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              token['symbol'],
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                _controller.forward().then((_) {
                                  _controller.reverse();
                        setState(() {
                          selectedTokens.add(token);
                          availableTokens.removeAt(index);
                                  });
                        });
                      },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
} 