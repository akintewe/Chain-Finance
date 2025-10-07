import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/att_manager.dart';
import '../../services/att_debug_helper.dart';
import '../../utils/colors.dart';
import '../../utils/text_styles.dart';

class ATTDebugScreen extends StatefulWidget {
  const ATTDebugScreen({super.key});

  @override
  State<ATTDebugScreen> createState() => _ATTDebugScreenState();
}

class _ATTDebugScreenState extends State<ATTDebugScreen> {
  Map<String, String> debugInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() => isLoading = true);
    final info = await ATTDebugHelper.getATTDebugInfo();
    setState(() {
      debugInfo = info;
      isLoading = false;
    });
  }

  Future<void> _requestATTAgain() async {
    setState(() => isLoading = true);
    await ATTManager.requestPermissionIfNeeded();
    await _loadDebugInfo();
  }

  Future<void> _resetATTState() async {
    setState(() => isLoading = true);
    await ATTManager.resetPermissionState();
    await ATTDebugHelper.clearDebugLog();
    await _loadDebugInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'ATT Debug Info',
          style: AppTextStyles.body2.copyWith(color: AppColors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Tracking Transparency Debug',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Current Status
                  _buildDebugCard(
                    'Current Status',
                    debugInfo['current_status'] ?? 'Unknown',
                    _getStatusColor(debugInfo['current_status']),
                  ),
                  
                  // Has Requested Before
                  _buildDebugCard(
                    'Has Requested Before',
                    debugInfo['has_requested_before'] ?? 'Unknown',
                    debugInfo['has_requested_before'] == 'true' 
                        ? Colors.orange 
                        : Colors.blue,
                  ),
                  
                  // Error Info
                  if (debugInfo['error'] != null)
                    _buildDebugCard(
                      'Error',
                      debugInfo['error']!,
                      Colors.red,
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _requestATTAgain,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Request ATT Again',
                            style: AppTextStyles.body2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _resetATTState,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Reset ATT State',
                            style: AppTextStyles.body2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Debug Log
                  Text(
                    'Debug Log',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.black),
                    ),
                    child: Text(
                      debugInfo['debug_log'] ?? 'No debug log available',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instructions for Testers',
                                        style: AppTextStyles.heading2.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. If status is "notDetermined" - ATT should show\n'
                          '2. If status is "denied" or "authorized" - ATT already handled\n'
                          '3. To reset: Delete app, reinstall, or use Reset button\n'
                          '4. Share this screen with developers if issues persist',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDebugCard(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: AppTextStyles.body2.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'TrackingStatus.authorized':
        return Colors.green;
      case 'TrackingStatus.denied':
        return Colors.red;
      case 'TrackingStatus.notDetermined':
        return Colors.orange;
      case 'TrackingStatus.restricted':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
