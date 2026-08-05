import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_nyumba/utils/api/api_client.dart';
import 'package:smart_nyumba/utils/providers/notifications_provider.dart';
import 'package:smart_nyumba/utils/providers/repairs_provider.dart';

const repairJson = {
  'id': 1,
  'email': 'tenant@test.com',
  'broken_property': 'Plumbing',
  'description_broken_property': 'Kitchen sink is leaking',
  'block_number': 'A',
  'house_number': '1',
  'status': 'pending',
  'created_at': '2026-07-12T21:26:19.286671Z',
  'updated_at': '2026-07-12T21:26:19.286682Z',
};

void main() {
  tearDown(() {
    ApiClient.httpClient = http.Client();
  });

  group('RepairsProvider', () {
    test('fetchAllRepairs populates status buckets', () async {
      ApiClient.httpClient = MockClient((request) async {
        expect(request.url.path, contains('caretaker-all-repairs'));
        return http.Response(
          jsonEncode({
            'status': true,
            'repairs': [
              repairJson,
              {...repairJson, 'id': 2, 'status': 'in_progress'},
              {...repairJson, 'id': 3, 'status': 'completed'},
            ],
          }),
          200,
        );
      });

      final provider = RepairsProvider();
      await provider.fetchAllRepairs();

      expect(provider.error, isNull);
      expect(provider.pendingRepairs.length, 1);
      expect(provider.inProgressRepairs.length, 1);
      expect(provider.completedRepairs.length, 1);
    });

    test('fetchAllRepairs surfaces backend errors', () async {
      ApiClient.httpClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'status': false, 'message': 'Role not allowed'}),
          400,
        );
      });

      final provider = RepairsProvider();
      await provider.fetchAllRepairs();

      expect(provider.error, 'Role not allowed');
      expect(provider.repairs, isEmpty);
    });

    test('updateStatus moves repair between buckets', () async {
      var call = 0;
      ApiClient.httpClient = MockClient((request) async {
        call++;
        if (call == 1) {
          return http.Response(
            jsonEncode({'status': true, 'repairs': [repairJson]}),
            200,
          );
        }
        expect(request.bodyFields['repair_id'], '1');
        expect(request.bodyFields['status'], 'in_progress');
        return http.Response(
          jsonEncode({'status': true, 'message': 'Repair status updated'}),
          200,
        );
      });

      final provider = RepairsProvider();
      await provider.fetchAllRepairs();
      final error = await provider.updateStatus(1, 'in_progress');

      expect(error, isNull);
      expect(provider.pendingRepairs, isEmpty);
      expect(provider.inProgressRepairs.length, 1);
    });

    test('submitRepair posts the form fields', () async {
      ApiClient.httpClient = MockClient((request) async {
        expect(request.url.path, contains('tenant-request-repair'));
        expect(request.bodyFields['email'], 'tenant@test.com');
        expect(request.bodyFields['broken_property'], 'Plumbing');
        return http.Response(
          jsonEncode({'status': true, 'message': 'Repair sent to admin!'}),
          200,
        );
      });

      final provider = RepairsProvider();
      final error = await provider.submitRepair(
        email: 'tenant@test.com',
        brokenProperty: 'Plumbing',
        description: 'Kitchen sink is leaking',
        blockNumber: 'A',
        houseNumber: '1',
      );

      expect(error, isNull);
    });

    test('network failure returns a friendly error', () async {
      ApiClient.httpClient = MockClient((request) async {
        throw Exception('connection refused');
      });

      final provider = RepairsProvider();
      await provider.fetchAllRepairs();
      expect(provider.error, contains('Check your connection'));
    });
  });

  group('NotificationsProvider', () {
    test('markAsRead reverts the optimistic update on failure', () async {
      var call = 0;
      ApiClient.httpClient = MockClient((request) async {
        call++;
        if (call == 1) {
          return http.Response(
            jsonEncode({
              'status': true,
              'notifications': [
                {
                  'id': 1,
                  'title': 'Hello',
                  'message': 'World',
                  'notification_type': 'system',
                  'read': false,
                  'created_at': '2026-07-12T21:26:31.155852Z',
                },
              ],
            }),
            200,
          );
        }
        return http.Response('server error', 500);
      });

      final provider = NotificationsProvider();
      await provider.fetchNotifications();
      expect(provider.unreadCount, 1);

      await provider.markAsRead(1);
      expect(provider.unreadCount, 1,
          reason: 'failed mark-read should revert');
    });

    test('markAllAsRead clears the unread count', () async {
      var call = 0;
      ApiClient.httpClient = MockClient((request) async {
        call++;
        if (call == 1) {
          return http.Response(
            jsonEncode({
              'status': true,
              'notifications': [
                {
                  'id': 1,
                  'title': 'A',
                  'message': 'x',
                  'notification_type': 'system',
                  'read': false,
                },
                {
                  'id': 2,
                  'title': 'B',
                  'message': 'y',
                  'notification_type': 'payment',
                  'read': false,
                },
              ],
            }),
            200,
          );
        }
        return http.Response(jsonEncode({'status': true}), 200);
      });

      final provider = NotificationsProvider();
      await provider.fetchNotifications();
      expect(provider.unreadCount, 2);

      await provider.markAllAsRead();
      expect(provider.unreadCount, 0);
    });
  });
}
