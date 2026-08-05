import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:smart_nyumba/screens/caretaker/repair_requests_screen.dart';
import 'package:smart_nyumba/utils/api/api_client.dart';
import 'package:smart_nyumba/utils/providers/repairs_provider.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  tearDown(() {
    ApiClient.httpClient = http.Client();
  });

  Widget buildScreen() {
    return ChangeNotifierProvider(
      create: (_) => RepairsProvider(),
      child: const MaterialApp(home: RepairRequestsScreen()),
    );
  }

  testWidgets('shows repairs from the API in the pending tab',
      (tester) async {
    ApiClient.httpClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'status': true,
          'repairs': [
            {
              'id': 1,
              'email': 'tenant@test.com',
              'broken_property': 'Plumbing',
              'description_broken_property': 'Kitchen sink is leaking',
              'block_number': 'A',
              'house_number': '1',
              'status': 'pending',
              'created_at': '2026-07-12T21:26:19.286671Z',
              'updated_at': '2026-07-12T21:26:19.286682Z',
            },
          ],
        }),
        200,
      );
    });

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Plumbing'), findsOneWidget);
    expect(find.text('Kitchen sink is leaking'), findsOneWidget);
    expect(find.text('Block A - House 1'), findsOneWidget);
    expect(find.text('Start Work'), findsOneWidget);
  });

  testWidgets('shows empty state when there are no repairs', (tester) async {
    ApiClient.httpClient = MockClient((request) async {
      return http.Response(
        jsonEncode({'status': true, 'repairs': []}),
        200,
      );
    });

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('No pending requests'), findsOneWidget);
  });

  testWidgets('shows retry button when the request fails', (tester) async {
    ApiClient.httpClient = MockClient((request) async {
      throw Exception('connection refused');
    });

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
  });
}
