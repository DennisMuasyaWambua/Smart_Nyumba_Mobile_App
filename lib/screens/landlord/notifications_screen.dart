import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  static const routeName = "/landlord-notifications";

  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Sample notifications data - would come from API in production
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'title': 'Payment Received',
      'message': 'Rent payment of KSh 15,000 received from tenant@email.com',
      'type': 'payment',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'read': false,
    },
    {
      'id': 2,
      'title': 'New Tenant Registered',
      'message': 'A new tenant has registered for House 12, Block A',
      'type': 'tenant',
      'date': DateTime.now().subtract(const Duration(hours: 5)),
      'read': false,
    },
    {
      'id': 3,
      'title': 'Payment Received',
      'message': 'Service charge payment of KSh 2,000 received',
      'type': 'payment',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'read': true,
    },
    {
      'id': 4,
      'title': 'Account Update',
      'message': 'Your landlord profile has been updated successfully',
      'type': 'system',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'read': true,
    },
  ];

  List<Map<String, dynamic>> get _unreadNotifications =>
      _notifications.where((n) => n['read'] == false).toList();

  void _markAsRead(int id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['read'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['read'] = true;
      }
    });
  }

  void _deleteNotification(int id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payments;
      case 'tenant':
        return Icons.person_add;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'payment':
        return Colors.green;
      case 'tenant':
        return Colors.blue;
      case 'system':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['read'] == true;
    final type = notification['type'] ?? 'system';
    final date = notification['date'] as DateTime;

    return Dismissible(
      key: Key(notification['id'].toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(notification['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _notifications.add(notification);
                });
              },
            ),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        elevation: isRead ? 0 : 2,
        color: isRead ? Colors.grey[50] : Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getNotificationColor(type).withOpacity(0.2),
            child: Icon(
              _getNotificationIcon(type),
              color: _getNotificationColor(type),
              size: 20,
            ),
          ),
          title: Text(
            notification['title'] ?? 'Notification',
            style: GoogleFonts.hind(
              fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
              fontSize: 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification['message'] ?? '',
                style: GoogleFonts.hind(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(date),
                style: GoogleFonts.hind(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          trailing: isRead
              ? null
              : Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
          onTap: () {
            if (!isRead) {
              _markAsRead(notification['id']);
            }
            _showNotificationDetails(notification);
          },
        ),
      ),
    );
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getNotificationIcon(notification['type'] ?? 'system'),
              color: _getNotificationColor(notification['type'] ?? 'system'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notification['title'] ?? 'Notification',
                style: GoogleFonts.hind(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['message'] ?? '',
              style: GoogleFonts.hind(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              _formatDate(notification['date'] as DateTime),
              style: GoogleFonts.hind(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNotification(notification['id']);
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Notifications',
              style: GoogleFonts.hind(fontWeight: FontWeight.w600),
            ),
            if (_unreadNotifications.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _unreadNotifications.length.toString(),
                  style: GoogleFonts.hind(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadNotifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: GoogleFonts.hind(fontSize: 12),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: GoogleFonts.hind(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re all caught up!',
                    style: GoogleFonts.hind(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(_notifications[index]);
              },
            ),
    );
  }
}
