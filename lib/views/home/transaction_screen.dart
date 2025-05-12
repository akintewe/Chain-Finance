import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String selectedFilter = 'All';
  DateTime? selectedDate;

  // Dummy transaction data
  final List<Map<String, dynamic>> transactions = [
    {
      'type': 'Received',
      'token': 'BTC',
      'amount': '0.025',
      'usdAmount': '\$875.50',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'from': '0x742d35Cc6...38f44e',
      'status': 'Completed',
      'icon': 'assets/icons/Cryptocurrency (2).png',
    },
    {
      'type': 'Sent',
      'token': 'ETH',
      'amount': '1.5',
      'usdAmount': '\$3,300.00',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'to': '0x892f35Dd6...42g44e',
      'status': 'Completed',
      'icon': 'assets/icons/Cryptocurrency (1).png',
    },
    {
      'type': 'Swapped',
      'fromToken': 'USDT',
      'toToken': 'TRX',
      'fromAmount': '1000',
      'toAmount': '12500',
      'usdAmount': '\$1,000.00',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Completed',
      'icon': 'assets/icons/Cryptocurrency.png',
    },
    // Add more dummy transactions...
  ];

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
      case 'Swapped':
        title = 'Swapped ${tx['fromToken']} to ${tx['toToken']}';
        subtitle = '${tx['fromAmount']} ${tx['fromToken']} → ${tx['toAmount']} ${tx['toToken']}';
        icon = Icons.swap_horiz;
        iconColor = Colors.blue;
        amountColor = AppColors.text;
        break;
      default:
        title = 'Unknown Transaction';
        subtitle = '';
        icon = Icons.help_outline;
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
            if (tx['type'] == 'Swapped') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'From',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tx['fromAmount']} ${tx['fromToken']}',
                          style: AppTextStyles.body2,
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'To',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${tx['toAmount']} ${tx['toToken']}',
                          style: AppTextStyles.body2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = getFilteredTransactions();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions',
                    style: AppTextStyles.heading.copyWith(fontSize: 32),
              ),
              Container(
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
                    TextButton(
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
                      child: _buildFilterChip('Swapped'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Transactions list
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
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
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          return _buildTransactionItem(filteredTransactions[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}