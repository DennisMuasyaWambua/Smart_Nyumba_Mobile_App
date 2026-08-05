import 'package:flutter_test/flutter_test.dart';
import 'package:smart_nyumba/utils/models/marketplace_item.dart';
import 'package:smart_nyumba/utils/models/notification_item.dart';
import 'package:smart_nyumba/utils/models/repair.dart';

void main() {
  group('Repair.fromJson', () {
    test('parses a full backend payload', () {
      final repair = Repair.fromJson({
        'id': 1,
        'email': 'tenant@test.com',
        'broken_property': 'Plumbing',
        'description_broken_property': 'Kitchen sink is leaking',
        'block_number': 'A',
        'house_number': '1',
        'status': 'pending',
        'created_at': '2026-07-12T21:26:19.286671Z',
        'updated_at': '2026-07-12T21:26:19.286682Z',
      });

      expect(repair.id, 1);
      expect(repair.email, 'tenant@test.com');
      expect(repair.brokenProperty, 'Plumbing');
      expect(repair.description, 'Kitchen sink is leaking');
      expect(repair.status, 'pending');
      expect(repair.location, 'Block A - House 1');
      expect(repair.createdAt, isNotNull);
    });

    test('tolerates missing optional fields', () {
      final repair = Repair.fromJson({
        'id': 2,
        'email': 'tenant@test.com',
        'broken_property': 'Electrical',
        'description_broken_property': 'No power',
        'block_number': null,
        'house_number': null,
        'status': 'in_progress',
        'created_at': null,
        'updated_at': null,
      });

      expect(repair.location, 'Location not specified');
      expect(repair.createdAt, isNull);
    });

    test('copyWith changes only the status', () {
      final repair = Repair.fromJson({
        'id': 3,
        'email': 'tenant@test.com',
        'broken_property': 'Plumbing',
        'description_broken_property': 'x',
        'status': 'pending',
      });
      final updated = repair.copyWith(status: 'completed');
      expect(updated.status, 'completed');
      expect(updated.id, repair.id);
      expect(updated.email, repair.email);
    });
  });

  group('NotificationItem.fromJson', () {
    test('parses a backend payload', () {
      final notification = NotificationItem.fromJson({
        'id': 5,
        'recipient_email': 'caretaker@test.com',
        'title': 'New Repair Request',
        'message': 'A repair was requested',
        'notification_type': 'repair',
        'read': false,
        'created_at': '2026-07-12T21:26:31.155852Z',
      });

      expect(notification.id, 5);
      expect(notification.title, 'New Repair Request');
      expect(notification.type, 'repair');
      expect(notification.read, isFalse);
      expect(notification.createdAt, isNotNull);
    });
  });

  group('MarketplaceItem.fromJson', () {
    test('parses a backend payload', () {
      final item = MarketplaceItem.fromJson({
        'id': 1,
        'goods_name': 'Sharon Sewing Services',
        'goods_description': 'Tailoring and repairs',
        'goods_quantity': '1',
        'any_offer': '10% off',
        'status': 1,
        'category': 'Sewing',
        'owner_email': 'tenant@test.com',
      });

      expect(item.name, 'Sharon Sewing Services');
      expect(item.category, 'Sewing');
      expect(item.published, isTrue);
    });

    test('defaults blank category to General', () {
      final item = MarketplaceItem.fromJson({
        'id': 2,
        'goods_name': 'Cakes',
        'goods_description': 'Baked goods',
        'goods_quantity': '3',
        'any_offer': '',
        'status': 0,
        'category': '',
        'owner_email': null,
      });

      expect(item.category, 'General');
      expect(item.published, isFalse);
    });
  });
}
