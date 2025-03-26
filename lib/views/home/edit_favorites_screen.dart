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

class _EditFavoritesScreenState extends State<EditFavoritesScreen> {
  final WalletController walletController = Get.find();
  final List<Map<String, dynamic>> selectedTokens = [];
  final List<Map<String, dynamic>> availableTokens = [];

  @override
  void initState() {
    super.initState();
    selectedTokens.addAll(walletController.favoritesList);
    availableTokens.addAll(
      walletController.cryptoList.where(
        (token) => !walletController.isFavorite(token['symbol'])
      ).toList()
    );
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
        backgroundColor: AppColors.background,
        title: Text('Edit Favorites', style: AppTextStyles.heading2),
        actions: [
          TextButton(
            onPressed: () {
              walletController.favoritesList.clear();
              walletController.favoritesList.addAll(selectedTokens);
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Drag to reorder favorites',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
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
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    setState(() {
                      availableTokens.add(token);
                      selectedTokens.removeAt(index);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.textSecondary.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: Image.asset(token['icon'], width: 32, height: 32),
                      title: Text(token['name'], style: AppTextStyles.body2),
                      subtitle: Text(token['symbol']),
                      trailing: const Icon(Icons.drag_handle),
                    ),
                  ),
                );
              },
            ),
          ),
          if (availableTokens.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Available Tokens',
                style: AppTextStyles.body2,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: availableTokens.length,
                itemBuilder: (context, index) {
                  final token = availableTokens[index];
                  return ListTile(
                    leading: Image.asset(token['icon'], width: 32, height: 32),
                    title: Text(token['name'], style: AppTextStyles.body2),
                    subtitle: Text(token['symbol']),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        setState(() {
                          selectedTokens.add(token);
                          availableTokens.removeAt(index);
                        });
                      },
                    ),
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