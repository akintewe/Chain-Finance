import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
    if (_hasRequestedATT) return;
    
    try {
      // Add a small delay to ensure UI is completely ready
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (mounted) {
        if (kDebugMode) {
          print("ATTWrapper: Requesting ATT permission...");
        }
        
        await ATTManager.requestPermissionIfNeeded();
        _hasRequestedATT = true;
        
        if (kDebugMode) {
          print("ATTWrapper: ATT permission request completed");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("ATTWrapper: Error requesting ATT permission: $e");
      }
      _hasRequestedATT = true; // Mark as attempted to avoid infinite retries
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
