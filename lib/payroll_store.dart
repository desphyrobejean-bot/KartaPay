import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class PayrollStore {
  static const _workersKey = 'kartappay_workers_v1';
  static const _trucksKey = 'kartappay_trucks_v1';
  static const _recordsKey = 'kartappay_records_v1';

  Future<List<T>> _readList<T>(
    String key,
    T Function(Map<String, dynamic>) decode,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(key);
    if (encoded == null) return [];
    try {
      final values = jsonDecode(encoded) as List<dynamic>;
      return values
          .map((value) => decode(value as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> _writeList<T>(
    String key,
    List<T> values,
    Map<String, dynamic> Function(T) encode,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, jsonEncode(values.map(encode).toList()));
  }

  Future<List<Worker>> getWorkers() => _readList(_workersKey, Worker.fromJson);

  Future<List<Truck>> getTrucks() => _readList(_trucksKey, Truck.fromJson);

  Future<List<PayrollRecord>> getRecords() async {
    final records = await _readList(_recordsKey, PayrollRecord.fromJson);
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  Future<void> saveWorker(Worker worker) async {
    final workers = await getWorkers();
    final index = workers.indexWhere((value) => value.id == worker.id);
    if (index == -1) {
      workers.add(worker);
    } else {
      workers[index] = worker;
    }
    await _writeList(_workersKey, workers, (value) => value.toJson());
  }

  Future<void> deleteWorker(String id) async {
    final workers = await getWorkers();
    workers.removeWhere((value) => value.id == id);
    await _writeList(_workersKey, workers, (value) => value.toJson());
  }

  Future<void> saveTruck(Truck truck) async {
    final trucks = await getTrucks();
    final index = trucks.indexWhere((value) => value.id == truck.id);
    if (index == -1) {
      trucks.add(truck);
    } else {
      trucks[index] = truck;
    }
    await _writeList(_trucksKey, trucks, (value) => value.toJson());
  }

  Future<void> deleteTruck(String id) async {
    final trucks = await getTrucks();
    trucks.removeWhere((value) => value.id == id);
    await _writeList(_trucksKey, trucks, (value) => value.toJson());
  }

  Future<void> saveRecord(PayrollRecord record) async {
    final records = await getRecords();
    records.insert(0, record);
    await _writeList(_recordsKey, records, (value) => value.toJson());
  }
}
