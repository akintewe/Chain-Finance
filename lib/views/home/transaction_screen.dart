import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexa_prime/services/api_service.dart';
import 'package:flutter/foundation.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String selectedFilter = 'All';
  DateTime? selectedDate;

  // Real transaction data from API
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getUserTransactions();
      
      if (response != null && response['status'] == true) {
        final List<dynamic> rawTransactions = response['data'] ?? [];
        
        if (kDebugMode) {
          print('Raw transactions count: ${rawTransactions.length}');
          print('Raw transactions: $rawTransactions');
        }
        
        // Transform API data to match our UI format
        transactions = rawTransactions.map((tx) {
          final type = tx['type'] ?? 'Unknown';
          final amount = tx['amount']?.toString() ?? '0';
          final currency = tx['currency'] ?? 'Unknown';
          final status = tx['status'] ?? 'Unknown';
          final createdAt = DateTime.tryParse(tx['created_at'] ?? '') ?? DateTime.now();
          
          // Determine transaction type for UI
          String uiType;
          if (type == 'send') {
            uiType = 'Sent';
          } else if (type == 'receive') {
            uiType = 'Received';
          } else {
            uiType = type;
          }
          
          return {
            'type': uiType,
            'token': currency,
            'amount': amount,
            'usdAmount': '\$${amount}', // You might want to get real USD conversion
            'date': createdAt,
            'from': tx['external_wallet_address'] ?? 'Unknown',
            'to': tx['external_wallet_address'] ?? 'Unknown',
            'status': status,
            'tx_id': tx['tx_id'],
            'note': tx['note'],
          };
        }).toList();
        
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = response?['message'] ?? 'Failed to fetch transactions';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Network error: $e';
      });
    }
  }

  List<Map<String, dynamic>> getFilteredTransactions() {
    return transactions.where((tx) {
      if (selectedDate != null) {
        final txDate = tx['date'] as DateTime;
        if (!DateUtils.isSameDay(txDate, selectedDate)) {
          return false;
        }
      }
      
      if (selectedFilter == 'All') return true;
      return tx['type'] == selectedFilter;
    }).toList();
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: selectedFilter == label,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            selectedFilter = label;
          });
        }
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selectedFilter == label ? AppColors.primary : AppColors.textSecondary,
        fontWeight: selectedFilter == label ? FontWeight.bold : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selectedFilter == label ? AppColors.primary : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    String title;
    String subtitle;
    IconData icon;
    Color iconColor;
    Color amountColor;

    switch (tx['type']) {
      case 'Received':
        title = 'Received ${tx['token']}';
        subtitle = 'From: ${tx['from']}';
        icon = Icons.arrow_downward;
        iconColor = Colors.green;
        amountColor = Colors.green;
        break;
      case 'Sent':
        title = 'Sent ${tx['token']}';
        subtitle = 'To: ${tx['to']}';
        icon = Icons.arrow_upward;
        iconColor = Colors.red;
        amountColor = Colors.red;
        break;
      case 'Pending':
        title = 'Pending ${tx['token']}';
        subtitle = 'Status: ${tx['status']}';
        icon = Icons.schedule;
        iconColor = Colors.orange;
        amountColor = Colors.orange;
        break;
      default:
        title = '${tx['type']} ${tx['token']}';
        subtitle = 'Status: ${tx['status']}';
        icon = Icons.receipt;
        iconColor = AppColors.textSecondary;
        amountColor = AppColors.text;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tx['usdAmount'],
                      style: AppTextStyles.body2.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
            Text(
                      DateFormat('MMM dd, HH:mm').format(tx['date']),
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
              ],
            ),
            if (tx['tx_id'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'TX: ${tx['tx_id']}',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (tx['note'] != null && tx['note'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Note: ${tx['note']}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading transactions...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading transactions',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchTransactions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (getFilteredTransactions().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (selectedFilter != 'All' || selectedDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: getFilteredTransactions().length,
      itemBuilder: (context, index) {
        return _buildTransactionItem(getFilteredTransactions()[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transactions',
                    style: AppTextStyles.heading.copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Refresh button
                      IconButton(
                        onPressed: _fetchTransactions,
                        icon: Icon(
                          Icons.refresh,
                          color: AppColors.primary,
                        ),
                        tooltip: 'Refresh transactions',
                      ),
                      const SizedBox(width: 8),
                      // Date picker
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.textSecondary,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate ?? DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        selectedDate = date;
                                      });
                                    }
                                  },
                                  child: Text(
                                    selectedDate != null
                                        ? DateFormat('MMM dd').format(selectedDate!)
                                        : 'Select Date',
                                    style: AppTextStyles.body2.copyWith(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              if (selectedDate != null) ...[
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedDate = null;
                                    });
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Filter chips
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip('All'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip('Sent'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip('Received'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip('Pending'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Transactions list
              Expanded(
                child: _buildTransactionsContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}