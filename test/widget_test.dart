import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/database/app_database.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/level_user.dart';
import 'package:flutter_application_1/models/permission.dart';
import 'package:flutter_application_1/models/class_poll_response.dart';
import 'package:flutter_application_1/pages/discount_page.dart';
import 'package:flutter_application_1/pages/max_min_page.dart';
import 'package:flutter_application_1/pages/poll_page.dart';
import 'package:flutter_application_1/pages/sorting_page.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/class_poll_repository.dart';
import 'package:flutter_application_1/services/permission_repository.dart';
import 'package:flutter_application_1/services/permission_service.dart';

void main() {
  testWidgets('class polling dashboard renders five chart types', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PollPage()));
    await tester.pump();

    expect(find.text('Berat badan'), findsOneWidget);
    expect(find.text('Tinggi badan'), findsOneWidget);
    expect(find.text('Ukuran baju'), findsOneWidget);
    expect(find.text('Nomor sepatu'), findsOneWidget);
    expect(find.text('Golongan darah'), findsOneWidget);
    expect(find.text('BAR'), findsOneWidget);
    expect(find.text('LINE'), findsOneWidget);
    expect(find.text('DONUT'), findsOneWidget);
    expect(find.text('SCATTER'), findsOneWidget);
    expect(find.text('RADAR'), findsOneWidget);
  });

  testWidgets('admin sees class response management controls', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final admin = (await AuthService().login('admin', 'admin123')).user!;

    await tester.pumpWidget(
      MaterialApp(
        home: PollPage(
          currentUser: admin,
          repository: MemoryClassPollRepository.seeded(),
        ),
      ),
    );
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Kelola data responden'),
      500,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Kelola data responden'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
    expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);
  });

  test(
    'class polling repository supports create, update, and delete',
    () async {
      final repository = MemoryClassPollRepository();
      const response = ClassPollResponse(
        name: 'Nadia',
        weight: 54,
        height: 163,
        shirtSize: 'M',
        shoeSize: 39,
        bloodType: 'A',
      );

      await repository.createResponse(response);
      var rows = await repository.watchResponses().first;
      expect(rows, hasLength(1));

      final saved = rows.single;
      await repository.updateResponse(saved.copyWith(weight: 56));
      rows = await repository.watchResponses().first;
      expect(rows.single.weight, 56);

      await repository.deleteResponse(saved.id!);
      rows = await repository.watchResponses().first;
      expect(rows, isEmpty);
    },
  );

  testWidgets('admin can login and access all menu features', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await _login(tester, 'admin', 'admin123');

    expect(find.text('Learning Hub'), findsOneWidget);
    expect(find.text('Fitur'), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'sorting');
    await tester.pumpAndSettle();

    expect(find.text('Sorting'), findsOneWidget);
    expect(find.text('Urutkan data angka'), findsOneWidget);
    expect(find.text('Kelola profil dan video anggota'), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'zodiac');
    await tester.pumpAndSettle();

    expect(find.text('Zodiac'), findsOneWidget);
    expect(find.text('Cek zodiak dari tanggal lahir'), findsOneWidget);

    await tester.tap(find.text('Fitur').last);
    await tester.pumpAndSettle();

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Access Control'), findsOneWidget);
    expect(find.text('Sorting'), findsOneWidget);
    expect(find.text('Max & Min'), findsOneWidget);
  });

  testWidgets('customer only sees customer-level features', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await _login(tester, 'customer', 'customer123');

    await tester.tap(find.text('Fitur').last);
    await tester.pumpAndSettle();

    expect(find.text('Polling'), findsWidgets);
    expect(find.text('Zodiac'), findsWidgets);
    expect(find.text('Create Account'), findsNothing);
    expect(find.text('Sorting'), findsNothing);
    expect(find.text('Calculator'), findsNothing);
    expect(find.text('Max & Min'), findsNothing);
  });

  testWidgets('blocked user cannot enter the app', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'blocked');
    await tester.enterText(find.byType(TextFormField).at(1), 'blocked123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.textContaining('berstatus no valid'), findsOneWidget);
    expect(find.text('Fitur populer'), findsNothing);
  });

  testWidgets('discount input safely limits oversized values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DiscountPage()));

    await tester.enterText(
      find.byType(TextField).first,
      '999999999999999999999999',
    );
    await tester.enterText(find.byType(TextField).last, '10');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Hitung'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Harga Akhir:'), findsOneWidget);
  });

  testWidgets('data analyzer rejects invalid tokens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MaxMinPage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '1\ninvalid\n3');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Hitung'));
    await tester.pump();

    expect(find.textContaining('Nilai tidak valid: invalid'), findsOneWidget);
    expect(find.text('Max'), findsNothing);
  });

  testWidgets('sorting rejects extra invalid input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SortingPage()));

    await tester.enterText(find.byType(TextField), '1,2,3,4,5,6,7,8,9,10,bad');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Proses Sorting'));
    await tester.pump();

    expect(
      find.text('Semua nilai harus berupa bilangan bulat.'),
      findsOneWidget,
    );
    expect(find.text('Bubble Sort'), findsNothing);
  });

  test('role permission overrides persist and replace defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = _MemoryPermissionRepository();
    await PermissionService.initialize(repository: repository);
    final login = await AuthService().login('customer', 'customer123');
    final customer = login.user!;

    expect(
      PermissionService.canAccess(customer, PermissionFeature.sorting),
      isFalse,
    );

    await PermissionService.updatePermissionForRole(
      LevelUser.customer,
      PermissionFeature.sorting,
      true,
    );
    expect(
      PermissionService.canAccess(customer, PermissionFeature.sorting),
      isTrue,
    );

    await PermissionService.initialize(repository: repository);
    expect(
      PermissionService.canAccess(customer, PermissionFeature.sorting),
      isTrue,
    );

    await PermissionService.updatePermissionForRole(
      LevelUser.customer,
      PermissionFeature.sorting,
      false,
    );
    expect(
      PermissionService.canAccess(customer, PermissionFeature.sorting),
      isFalse,
    );
  });

  test(
    'user permission overrides take precedence over role permissions',
    () async {
      SharedPreferences.setMockInitialValues({});
      final login = await AuthService().login('customer', 'customer123');
      final customer = login.user!.copyWith(authId: 'test-user-id');
      final repository = _MemoryPermissionRepository(
        userPermissions: {
          customer.authId!: {PermissionFeature.sorting: true},
        },
      );

      await PermissionService.initialize(
        repository: repository,
        user: customer,
      );

      expect(
        PermissionService.canAccess(customer, PermissionFeature.sorting),
        isTrue,
      );
    },
  );

  test('Zodiac records support Drift SQLite CRUD', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    final id = await database.createZodiacRecord(
      _zodiacRecord(
        day: 21,
        month: 6,
        zodiacName: 'Cancer',
        dateRange: '21 Juni - 22 Juli',
        element: 'Air',
        symbol: 'Kepiting',
      ),
    );

    var records = await database.watchZodiacRecords().first;
    expect(records, hasLength(1));
    expect(records.single.id, id);
    expect(records.single.zodiacName, 'Cancer');

    await database.updateZodiacRecord(
      id: id,
      record: _zodiacRecord(
        day: 23,
        month: 7,
        zodiacName: 'Leo',
        dateRange: '23 Juli - 22 Agustus',
        element: 'Api',
        symbol: 'Singa',
      ),
    );

    records = await database.watchZodiacRecords().first;
    expect(records, hasLength(1));
    expect(records.single.zodiacName, 'Leo');
    expect(records.single.day, 23);

    await database.deleteZodiacRecord(id);

    records = await database.watchZodiacRecords().first;
    expect(records, isEmpty);
  });
}

class _MemoryPermissionRepository implements PermissionRepository {
  final Map<LevelUser, Map<PermissionFeature, bool>> rolePermissions;
  final Map<String, Map<PermissionFeature, bool>> userPermissions;

  _MemoryPermissionRepository({
    Map<LevelUser, Map<PermissionFeature, bool>>? rolePermissions,
    Map<String, Map<PermissionFeature, bool>>? userPermissions,
  }) : rolePermissions = rolePermissions ?? {},
       userPermissions = userPermissions ?? {};

  @override
  Future<Map<PermissionFeature, bool>> getPermissionsForRole(
    LevelUser role,
  ) async {
    return Map.of(rolePermissions[role] ?? const {});
  }

  @override
  Future<Map<PermissionFeature, bool>> getPermissionsForUser(
    String userId,
  ) async {
    return Map.of(userPermissions[userId] ?? const {});
  }

  @override
  Future<void> updatePermissionForRole(
    LevelUser role,
    PermissionFeature feature,
    bool allowed,
  ) async {
    (rolePermissions[role] ??= {})[feature] = allowed;
  }

  @override
  Future<void> updatePermissionForUser(
    String userId,
    PermissionFeature feature,
    bool allowed,
  ) async {
    (userPermissions[userId] ??= {})[feature] = allowed;
  }
}

Future<void> _login(
  WidgetTester tester,
  String username,
  String password,
) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();

  expect(find.text('Login'), findsOneWidget);

  await tester.enterText(find.byType(TextFormField).at(0), username);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();

  expect(find.text('Fitur'), findsOneWidget);
}

ZodiacRecordsCompanion _zodiacRecord({
  required int day,
  required int month,
  required String zodiacName,
  required String dateRange,
  required String element,
  required String symbol,
}) {
  return ZodiacRecordsCompanion.insert(
    day: day,
    month: month,
    zodiacName: zodiacName,
    dateRange: dateRange,
    character: 'Karakter umum',
    strengths: 'Kelebihan',
    weaknesses: 'Kekurangan',
    compatible: 'Zodiak cocok',
    lessCompatible: 'Zodiak kurang cocok',
    element: element,
    symbol: symbol,
    accentValue: 0xFF123D73,
  );
}
