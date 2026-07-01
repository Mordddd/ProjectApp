import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/class_poll_response.dart';

abstract class ClassPollRepository {
  String get storageLabel;

  Stream<List<ClassPollResponse>> watchResponses();

  Future<void> createResponse(ClassPollResponse response);

  Future<void> updateResponse(ClassPollResponse response);

  Future<void> deleteResponse(String id);
}

class SupabaseClassPollRepository implements ClassPollRepository {
  final SupabaseClient client;

  SupabaseClassPollRepository(this.client);

  @override
  String get storageLabel => 'Supabase';

  String get _userId {
    final id = client.auth.currentUser?.id;
    if (id == null) throw StateError('Pengguna harus login terlebih dahulu.');
    return id;
  }

  @override
  Stream<List<ClassPollResponse>> watchResponses() {
    return client
        .from('class_poll_responses')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map(
          (rows) =>
              rows.map(ClassPollResponse.fromSupabase).toList(growable: false),
        );
  }

  @override
  Future<void> createResponse(ClassPollResponse response) async {
    await client.from('class_poll_responses').insert({
      ...response.toSupabase(),
      'submitted_by': _userId,
    });
  }

  @override
  Future<void> updateResponse(ClassPollResponse response) async {
    final id = response.id;
    if (id == null) throw ArgumentError('ID respons wajib tersedia.');
    await client
        .from('class_poll_responses')
        .update(response.toSupabase())
        .eq('id', id);
  }

  @override
  Future<void> deleteResponse(String id) async {
    await client.from('class_poll_responses').delete().eq('id', id);
  }
}

class MemoryClassPollRepository implements ClassPollRepository {
  final List<ClassPollResponse> _responses;
  final _changes = StreamController<List<ClassPollResponse>>.broadcast();
  var _nextId = 1;

  MemoryClassPollRepository({List<ClassPollResponse> responses = const []})
    : _responses = [...responses];

  factory MemoryClassPollRepository.seeded() {
    return MemoryClassPollRepository(
      responses: const [
        ClassPollResponse(
          id: '1',
          name: 'Alya',
          weight: 47,
          height: 156,
          shirtSize: 'S',
          shoeSize: 37,
          bloodType: 'A',
        ),
        ClassPollResponse(
          id: '2',
          name: 'Bagas',
          weight: 68,
          height: 174,
          shirtSize: 'L',
          shoeSize: 42,
          bloodType: 'O',
        ),
        ClassPollResponse(
          id: '3',
          name: 'Citra',
          weight: 52,
          height: 160,
          shirtSize: 'M',
          shoeSize: 38,
          bloodType: 'B',
        ),
        ClassPollResponse(
          id: '4',
          name: 'Dimas',
          weight: 73,
          height: 178,
          shirtSize: 'XL',
          shoeSize: 43,
          bloodType: 'O',
        ),
        ClassPollResponse(
          id: '5',
          name: 'Eka',
          weight: 49,
          height: 158,
          shirtSize: 'S',
          shoeSize: 37,
          bloodType: 'AB',
        ),
        ClassPollResponse(
          id: '6',
          name: 'Farhan',
          weight: 64,
          height: 171,
          shirtSize: 'L',
          shoeSize: 41,
          bloodType: 'A',
        ),
      ],
    );
  }

  @override
  String get storageLabel => 'Data lokal';

  @override
  Stream<List<ClassPollResponse>> watchResponses() async* {
    yield List.unmodifiable(_responses);
    yield* _changes.stream;
  }

  void _emit() => _changes.add(List.unmodifiable(_responses));

  @override
  Future<void> createResponse(ClassPollResponse response) async {
    _responses.add(response.copyWith(id: 'local-${_nextId++}'));
    _emit();
  }

  @override
  Future<void> updateResponse(ClassPollResponse response) async {
    final index = _responses.indexWhere((item) => item.id == response.id);
    if (index < 0) throw StateError('Respons tidak ditemukan.');
    _responses[index] = response;
    _emit();
  }

  @override
  Future<void> deleteResponse(String id) async {
    _responses.removeWhere((item) => item.id == id);
    _emit();
  }
}
