import 'package:http/http.dart' as http;
import 'dart:convert';

class PriceService {
  static const String baseUrl = 'https://rest.coinapi.io/v1';
  static const String apiKey = '81e48921-999e-47bb-b043-c6561ca82dc9';

  static Future<Map<String, dynamic>> getAllRates(String baseAsset) async {
    try {
      print('Fetching rates for $baseAsset');
      final response = await http.get(
        Uri.parse('$baseUrl/exchangerate/$baseAsset'),
        headers: {
          'X-CoinAPI-Key': apiKey,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch rates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllRates: $e');
      throw Exception('Error fetching rates: $e');
    }
  }

  static Future<double> getSpecificRate(String baseAsset, String quoteAsset) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/exchangerate/$baseAsset/$quoteAsset'),
        headers: {
          'X-CoinAPI-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['rate'].toDouble();
      } else {
        throw Exception('Failed to fetch rate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching rate: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getHistoricalRates(
    String baseAsset,
    String quoteAsset, {
    String periodId = '1DAY',
    required DateTime timeStart,
    required DateTime timeEnd,
    int limit = 30,
  }) async {
    try {
      // Format the dates correctly for the API
      final formattedStart = timeStart.toUtc().toIso8601String().split('.')[0];
      final formattedEnd = timeEnd.toUtc().toIso8601String().split('.')[0];
      
      final url = '$baseUrl/exchangerate/$baseAsset/$quoteAsset/history?'
          'period_id=$periodId'
          '&time_start=${formattedStart}Z'
          '&time_end=${formattedEnd}Z'
          '&limit=$limit';
          
      print('Fetching historical rates from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-CoinAPI-Key': apiKey,
          'Accept': 'application/json',
        },
      );

      print('Historical rates response status: ${response.statusCode}');
      print('Historical rates response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to fetch historical rates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getHistoricalRates: $e');
      throw Exception('Error fetching historical rates: $e');
    }
  }

  static Future<Map<String, dynamic>> getAssetMetrics(String assetId) async {
    try {
      // Using 'COINBASE' as a default exchange, you might want to make this configurable
      final url = '$baseUrl/metrics/asset/current?asset_id=$assetId&exchange_id=COINBASE';
      print('Fetching asset metrics from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-CoinAPI-Key': apiKey,
          'Accept': 'application/json',
        },
      );

      print('Asset metrics response status: ${response.statusCode}');
      print('Asset metrics response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final metrics = <String, dynamic>{};
        
        for (var metric in data) {
          print('Processing metric: $metric');
          final metricId = metric['metric_id']?.toString().toLowerCase();
          final value = metric['value_decimal'];
          
          if (metricId != null && value != null) {
            metrics[metricId] = value;
          }
        }
        
        return metrics;
      } else {
        print('Failed to fetch metrics: ${response.body}');
        // Fallback to dummy data on error
        return _getDummyMetrics(assetId);
      }
    } catch (e) {
      print('Error in getAssetMetrics: $e');
      return _getDummyMetrics(assetId);
    }
  }

  static Map<String, dynamic> _getDummyMetrics(String assetId) {
    // Different dummy data for different assets
    switch (assetId) {
      case 'BTC':
        return {
          'market_cap': 1000000000000,
          'volume_24h': 50000000000,
          'circulating_supply': 19500000,
          'total_supply': 21000000,
        };
      case 'ETH':
        return {
          'market_cap': 300000000000,
          'volume_24h': 20000000000,
          'circulating_supply': 120000000,
          'total_supply': 120000000,
        };
      default:
        return {
          'market_cap': 10000000000,
          'volume_24h': 1000000000,
          'circulating_supply': 1000000000,
          'total_supply': 1000000000,
        };
    }
  }

  static Future<Map<String, dynamic>> getOrderBook(String symbol, double currentPrice) async {
    try {
      final symbolId = 'BINANCE_SPOT_${symbol}_USDT';
      final url = '$baseUrl/orderbooks3/current?filter_symbol_id=$symbolId&limit_levels=5';
      print('Fetching order book from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-CoinAPI-Key': apiKey,
          'Accept': 'application/json',
        },
      );

      print('Order book response status: ${response.statusCode}');
      print('Order book response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return {
            'asks': data[0]['asks'] ?? [],
            'bids': data[0]['bids'] ?? [],
            'time': data[0]['time_exchange'],
          };
        }
      }
      return _getDummyOrderBook(currentPrice);
    } catch (e) {
      print('Error in getOrderBook: $e');
      return _getDummyOrderBook(currentPrice);
    }
  }

  static Map<String, dynamic> _getDummyOrderBook(double currentPrice) {
    return {
      'asks': List.generate(5, (i) => {
        'price': (currentPrice * (1 + 0.001 * (i + 1))).toString(),
        'size': (1.0 / (i + 1)).toString(),
      }),
      'bids': List.generate(5, (i) => {
        'price': (currentPrice * (1 - 0.001 * (i + 1))).toString(),
        'size': (1.0 / (i + 1)).toString(),
      }),
      'time': DateTime.now().toIso8601String(),
    };
  }
} 