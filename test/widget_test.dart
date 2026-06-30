import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/database/app_database.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/level_user.dart';
import 'package:flutter_application_1/models/permission.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/permission_repository.dart';
import 'package:flutter_application_1/services/permission_service.dart';

void main() {
  testWidgets('admin can login and access all menu features', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await _login(tester, 'admin', 'admin123');

    expect(find.text('Learning Hub'), findsOneWidget);
    expect(find.text('Fitur populer'), findsOneWidget);
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

  expect(find.text('Fitur populer'), findsOneWidget);
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
