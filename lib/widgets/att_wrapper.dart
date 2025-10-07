import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import '../services/att_manager.dart';

/// Widget that ensures ATT permission is requested when the app UI is ready
class ATTWrapper extends StatefulWidget {
  final Widget child;
  
  const ATTWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ATTWrapper> createState() => _ATTWrapperState();
}

class _ATTWrapperState extends State<ATTWrapper> with WidgetsBindingObserver {
  bool _hasRequestedATT = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Request ATT permission after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestATTPermissionIfNeeded();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Request ATT permission when app becomes active (in case it was missed)
    if (state == AppLifecycleState.resumed && !_hasRequestedATT) {
      _requestATTPermissionIfNeeded();
    }
  }

  Future<void> _requestATTPermissionIfNeeded() async {
    if (_hasRequestedATT && _retryCount >= _maxRetries) return;
    
    try {
      // Multiple timing attempts for different iOS versions
      final delays = [200, 500, 1000]; // ms
      final delay = _retryCount < delays.length ? delays[_retryCount] : 1000;
      
      await Future.delayed(Duration(milliseconds: delay));
      
      if (mounted) {
        if (kDebugMode) {
          print("ATTWrapper: Requesting ATT permission (attempt ${_retryCount + 1})...");
        }
        
        await ATTManager.requestPermissionIfNeeded();
        
        // Check if the request actually worked
        final status = await ATTManager.getCurrentStatus();
        if (status == TrackingStatus.notDetermined && _retryCount < _maxRetries) {
          // Still notDetermined, retry with different timing
          _retryCount++;
          if (kDebugMode) {
            print("ATTWrapper: ATT still notDetermined, retrying...");
          }
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _requestATTPermissionIfNeeded();
            }
          });
        } else {
          _hasRequestedATT = true;
          if (kDebugMode) {
            print("ATTWrapper: ATT permission request completed with status: $status");
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("ATTWrapper: Error requesting ATT permission: $e");
      }
      _retryCount++;
      if (_retryCount < _maxRetries) {
        // Retry after error
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _requestATTPermissionIfNeeded();
          }
        });
      } else {
        _hasRequestedATT = true; // Stop after max retries
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
