import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';
import 'package:nexa_prime/utils/responsive_helper.dart';
import 'package:nexa_prime/services/price_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' show min, max;

class TokenInfoScreen extends StatefulWidget {
  final Map<String, dynamic> token;
  final double currentPrice;
  final double priceChange;

  const TokenInfoScreen({
    Key? key,
    required this.token,
    required this.currentPrice,
    required this.priceChange,
  }) : super(key: key);

  @override
  State<TokenInfoScreen> createState() => _TokenInfoScreenState();
}

class _TokenInfoScreenState extends State<TokenInfoScreen> {
  List<FlSpot> chartData = [];
  bool isLoading = true;
  String selectedTimeframe = '1D';
  final timeframes = ['1H', '1D', '1W', '1M', '1Y'];
  Map<String, dynamic>? tokenMetrics;
  Map<String, dynamic>? orderBookData;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    fetchChartData();
    fetchTokenMetrics();
    fetchOrderBook();
  }
  
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchChartData() async {
    if (_disposed) return;
    
    try {
      if (mounted) setState(() => isLoading = true);
      
      final timeEnd = DateTime.now();
      final timeStart = getTimeframeStartDate(timeEnd);
      
      final historicalData = await PriceService.getHistoricalRates(
        widget.token['symbol'],
        'USD',
        timeStart: timeStart,
        timeEnd: timeEnd,
        periodId: _getTimeframePeriod(selectedTimeframe),
      );

      // Normalize the data points
      final prices = historicalData.map((data) => data['rate_close'] as double).toList();
      final minPrice = prices.reduce(min);
      final maxPrice = prices.reduce(max);
      final priceRange = maxPrice - minPrice;

      chartData = historicalData.asMap().entries.map((entry) {
        final rate = entry.value['rate_close'] as double;
        // Normalize between 0 and 1, then scale to chart height
        final normalizedRate = (rate - minPrice) / priceRange;
        return FlSpot(
          entry.key.toDouble(),
          normalizedRate,
        );
      }).toList();

    } catch (e) {
      print('Error fetching chart data: $e');
      if (mounted) Get.snackbar('Error', 'Failed to load chart data: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> fetchTokenMetrics() async {
    if (_disposed) return;
    
    try {
      final metrics = await PriceService.getAssetMetrics(widget.token['symbol']);
      if (mounted) setState(() => tokenMetrics = metrics);
    } catch (e) {
      print('Error fetching metrics: $e');
    }
  }

  Future<void> fetchOrderBook() async {
    if (_disposed) return;
    
    try {
      final data = await PriceService.getOrderBook(widget.token['symbol'], widget.currentPrice);
      if (mounted) setState(() => orderBookData = data);
    } catch (e) {
      print('Error fetching order book: $e');
    }
  }

  String _getTimeframePeriod(String timeframe) {
    switch (timeframe) {
      case '1H':
        return '5MIN';
      case '1D':
        return '1HRS';
      case '1W':
        return '6HRS';
      case '1M':
        return '1DAY';
      case '1Y':
        return '1DAY';
      default:
        return '1HRS';
    }
  }

  DateTime getTimeframeStartDate(DateTime end) {
    switch (selectedTimeframe) {
      case '1H':
        return end.subtract(const Duration(hours: 1));
      case '1D':
        return end.subtract(const Duration(days: 1));
      case '1W':
        return end.subtract(const Duration(days: 7));
      case '1M':
        return end.subtract(const Duration(days: 30));
      case '1Y':
        return end.subtract(const Duration(days: 365));
      default:
        return end.subtract(const Duration(days: 1));
    }
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
        title: Text(widget.token['name'], style: AppTextStyles.body2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: ResponsiveHelper.getResponsiveAllPadding(context, all: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price and Change Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\$${widget.currentPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.heading.copyWith(fontSize: 32),
                      ),
                      Text(
                        '${widget.priceChange >= 0 ? '+' : ''}${widget.priceChange.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: widget.priceChange >= 0 ? Colors.green : Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Image.asset(widget.token['icon'], width: 48, height: 48),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Chart Section
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Timeframe Selector
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: timeframes.length,
                        itemBuilder: (context, index) {
                          final timeframe = timeframes[index];
                          final isSelected = timeframe == selectedTimeframe;
                          return _buildTimeframeButton(timeframe, isSelected);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Chart
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : LineChart(
                              LineChartData(
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: chartData,
                                    isCurved: true,
                                    color: AppColors.primary,
                                    barWidth: 2,
                                    dotData: FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: AppColors.primary.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Token Info Section
              Text('About ${widget.token['name']}',
                  style: AppTextStyles.heading2),
              const SizedBox(height: 16),
              _buildOrderBook(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframeButton(String timeframe, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (mounted) {
        setState(() => selectedTimeframe = timeframe);
        fetchChartData();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          timeframe,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.text,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderBook() {
    if (orderBookData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Book', style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bids', style: TextStyle(color: Colors.green)),
                    ...List.generate(
                      min(5, (orderBookData?['bids'] ?? []).length),
                      (i) => _buildOrderRow(
                        orderBookData!['bids'][i]['price'].toString(),
                        orderBookData!['bids'][i]['size'].toString(),
                        true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Asks', style: TextStyle(color: Colors.red)),
                    ...List.generate(
                      min(5, (orderBookData?['asks'] ?? []).length),
                      (i) => _buildOrderRow(
                        orderBookData!['asks'][i]['price'].toString(),
                        orderBookData!['asks'][i]['size'].toString(),
                        false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRow(String price, String amount, bool isBid) {
    try {
      final priceValue = double.tryParse(price) ?? 0.0;
      final amountValue = double.tryParse(amount) ?? 0.0;
      
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(
              '\$${priceValue.toStringAsFixed(2)}',
              style: TextStyle(
                color: isBid ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              amountValue.toStringAsFixed(4),
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }
} 