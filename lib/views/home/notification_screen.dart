import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nexa_prime/utils/colors.dart';
import 'package:nexa_prime/utils/text_styles.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'title': 'Price Alert',
      'message': 'Bitcoin (BTC) has increased by 5.2% in the last hour',
      'type': 'price_alert',
      'time': '2 minutes ago',
      'isRead': false,
      'icon': Icons.trending_up,
      'color': Colors.green,
      'crypto': 'BTC',
    },
    {
      'id': '2',
      'title': 'Transaction Completed',
      'message': 'You have successfully sent 0.5 ETH to external wallet',
      'type': 'transaction',
      'time': '15 minutes ago',
      'isRead': false,
      'icon': Icons.check_circle,
      'color': AppColors.primary,
      'crypto': 'ETH',
    },
    {
      'id': '3',
      'title': 'Price Alert',
      'message': 'Ethereum (ETH) has dropped below \$2,000',
      'type': 'price_alert',
      'time': '1 hour ago',
      'isRead': true,
      'icon': Icons.trending_down,
      'color': Colors.red,
      'crypto': 'ETH',
    },
    {
      'id': '4',
      'title': 'New Feature',
      'message': 'Staking is now available for your cryptocurrencies!',
      'type': 'feature',
      'time': '3 hours ago',
      'isRead': true,
      'icon': Icons.new_releases,
      'color': AppColors.secondary,
      'crypto': null,
    },
    {
      'id': '5',
      'title': 'Security Alert',
      'message': 'New login detected from iOS device',
      'type': 'security',
      'time': '6 hours ago',
      'isRead': true,
      'icon': Icons.security,
      'color': Colors.orange,
      'crypto': null,
    },
    {
      'id': '6',
      'title': 'Weekly Report',
      'message': 'Your portfolio gained +12.5% this week. View detailed report.',
      'type': 'report',
      'time': '1 day ago',
      'isRead': true,
      'icon': Icons.analytics,
      'color': Colors.blue,
      'crypto': null,
    },
    {
      'id': '7',
      'title': 'Price Alert',
      'message': 'Solana (SOL) has reached your target price of \$150',
      'type': 'price_alert',
      'time': '2 days ago',
      'isRead': true,
      'icon': Icons.flag,
      'color': Colors.green,
      'crypto': 'SOL',
    },
    {
      'id': '8',
      'title': 'Market News',
      'message': 'Bitcoin ETF approval boosts crypto market sentiment',
      'type': 'news',
      'time': '3 days ago',
      'isRead': true,
      'icon': Icons.article,
      'color': Colors.purple,
      'crypto': 'BTC',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        notifications[index]['isRead'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
    });
  }

  int get unreadCount => notifications.where((n) => !n['isRead']).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Get.back(),
        ),
        title: Text('Notifications', style: AppTextStyles.heading2),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark All Read',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Notification Count
            if (unreadCount > 0)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$unreadCount unread notification${unreadCount != 1 ? 's' : ''}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // Notifications List
            Expanded(
              child: notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _buildNotificationItem(notification, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    final isRead = notification['isRead'] as bool;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? AppColors.surface : AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead 
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.3),
          width: isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(isRead ? 0.05 : 0.1),
            blurRadius: isRead ? 6 : 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _markAsRead(notification['id']),
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (notification['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            notification['icon'] as IconData,
            color: notification['color'] as Color,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification['title'],
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              notification['message'],
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (notification['crypto'] != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      notification['crypto'],
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  notification['time'],
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: _getNotificationTypeIcon(notification['type']),
      ),
    );
  }

  Widget _getNotificationTypeIcon(String type) {
    IconData icon;
    Color color;
    
    switch (type) {
      case 'price_alert':
        icon = Icons.show_chart;
        color = Colors.orange;
        break;
      case 'transaction':
        icon = Icons.swap_horiz;
        color = AppColors.primary;
        break;
      case 'security':
        icon = Icons.shield;
        color = Colors.red;
        break;
      case 'feature':
        icon = Icons.star;
        color = AppColors.secondary;
        break;
      case 'report':
        icon = Icons.assessment;
        color = Colors.blue;
        break;
      case 'news':
        icon = Icons.newspaper;
        color = Colors.purple;
        break;
      default:
        icon = Icons.notifications;
        color = AppColors.textSecondary;
    }
    
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 48,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: AppTextStyles.heading2.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 12),
          Text(
            'You\'re all caught up!\nWe\'ll notify you of important updates.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 