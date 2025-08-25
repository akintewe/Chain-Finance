import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';

class CandlestickChartWidget extends StatefulWidget {
  final RxMap<String, double> chartData;
  final List<Color> chartColors;
  final String? selectedToken;
  final Function(String)? onTokenSelected;

  const CandlestickChartWidget({
    Key? key,
    required this.chartData,
    required this.chartColors,
    this.selectedToken,
    this.onTokenSelected,
  }) : super(key: key);

  @override
  State<CandlestickChartWidget> createState() => _CandlestickChartWidgetState();
}

class _CandlestickChartWidgetState extends State<CandlestickChartWidget> {
  // Completely static data - no animations, no movement
  List<Map<String, dynamic>> _candlestickData = [];
  bool _isLoading = true;
  String? _currentToken;

  @override
  void initState() {
    super.initState();
    _generateCandlestickData();
  }

  void _generateCandlestickData() {
    _candlestickData = [];
    
    // Use selected token or show portfolio data
    if (widget.selectedToken != null && widget.chartData.containsKey(widget.selectedToken)) {
      _currentToken = widget.selectedToken;
      final basePrice = widget.chartData[widget.selectedToken] ?? 100.0;
      
      // Generate static candlestick data for selected token
      for (int i = 0; i < 24; i++) {
        final volatility = 0.015; // 1.5% volatility for more stable chart
        
        // Create realistic but stable price movement
        final open = basePrice * (1 + (i * 0.0005) + (Random().nextDouble() - 0.5) * volatility);
        final close = open * (1 + (Random().nextDouble() - 0.5) * volatility);
        final high = max(open, close) * (1 + Random().nextDouble() * 0.008);
        final low = min(open, close) * (1 - Random().nextDouble() * 0.008);
        
        _candlestickData.add({
          'open': open,
          'high': high,
          'low': low,
          'close': close,
          'isGreen': close > open,
        });
      }
    } else {
      // Show portfolio overview with no specific token
      _currentToken = null;
      final baseValue = 1000.0; // Base portfolio value
      
      for (int i = 0; i < 24; i++) {
        final volatility = 0.01; // 1% volatility for portfolio
        
        final open = baseValue * (1 + (i * 0.001) + (Random().nextDouble() - 0.5) * volatility);
        final close = open * (1 + (Random().nextDouble() - 0.5) * volatility);
        final high = max(open, close) * (1 + Random().nextDouble() * 0.005);
        final low = min(open, close) * (1 - Random().nextDouble() * 0.005);
        
        _candlestickData.add({
          'open': open,
          'high': high,
          'low': low,
          'close': close,
          'isGreen': close > open,
        });
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void didUpdateWidget(CandlestickChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only regenerate data if the selected token changes
    if (oldWidget.selectedToken != widget.selectedToken) {
      _generateCandlestickData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading chart data...',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_candlestickData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No chart data available',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentToken != null ? '$_currentToken Chart' : 'Portfolio Overview',
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_currentToken != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Click tokens below to switch view',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      'Portfolio performance overview',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '24H',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: CandlestickPainter(
                candlestickData: _candlestickData,
                chartColors: widget.chartColors,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CandlestickPainter extends CustomPainter {
  final List<Map<String, dynamic>> candlestickData;
  final List<Color> chartColors;

  CandlestickPainter({
    required this.candlestickData,
    required this.chartColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candlestickData.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final candleWidth = (size.width - 40) / candlestickData.length;
    final maxPrice = candlestickData.map((e) => e['high'] as double).reduce(max);
    final minPrice = candlestickData.map((e) => e['low'] as double).reduce(min);
    final priceRange = maxPrice - minPrice;

    if (priceRange == 0) return;

    for (int i = 0; i < candlestickData.length; i++) {
      final candle = candlestickData[i];
      final x = 20 + (i * candleWidth) + (candleWidth / 2);
      
      // Calculate y positions
      final openY = size.height - 40 - ((candle['open'] - minPrice) / priceRange) * (size.height - 80);
      final closeY = size.height - 40 - ((candle['close'] - minPrice) / priceRange) * (size.height - 80);
      final highY = size.height - 40 - ((candle['high'] - minPrice) / priceRange) * (size.height - 80);
      final lowY = size.height - 40 - ((candle['low'] - minPrice) / priceRange) * (size.height - 80);

      // Draw wick (high to low line)
      paint.color = candle['isGreen'] ? Colors.green : Colors.red;
      paint.strokeWidth = 1.0;
      canvas.drawLine(
        Offset(x, highY),
        Offset(x, lowY),
        paint,
      );

      // Draw candle body
      paint.strokeWidth = candleWidth * 0.8;
      final candleHeight = (closeY - openY).abs();
      final candleY = candle['isGreen'] ? closeY : openY;
      
      if (candleHeight > 0) {
        canvas.drawLine(
          Offset(x, candleY),
          Offset(x, candleY + candleHeight),
          paint,
        );
      } else {
        // Doji - just a line
        canvas.drawLine(
          Offset(x, openY),
          Offset(x, openY + 1),
          paint,
        );
      }
    }

    // Draw grid lines
    paint.color = AppColors.textSecondary.withOpacity(0.1);
    paint.strokeWidth = 0.5;
    
    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = 20 + (i * (size.height - 40) / 4);
      canvas.drawLine(
        Offset(20, y),
        Offset(size.width - 20, y),
        paint,
      );
    }

    // Vertical grid lines
    for (int i = 0; i <= 4; i++) {
      final x = 20 + (i * (size.width - 40) / 4);
      canvas.drawLine(
        Offset(x, 20),
        Offset(x, size.height - 20),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false; // Never repaint - completely static
}
