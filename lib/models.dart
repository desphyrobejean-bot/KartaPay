enum WorkerType { pakyaw, driver }

List<double> equalShares(double amount, int count) {
  if (amount < 0 || count <= 0) return [];
  final cents = (amount * 100).round();
  final each = cents ~/ count;
  final remainder = cents % count;
  return List.generate(
    count,
    (index) => (each + (index < remainder ? 1 : 0)) / 100,
  );
}

class Worker {
  const Worker({
    required this.id,
    required this.name,
    required this.contact,
    required this.type,
  });

  final String id;
  final String name;
  final String contact;
  final WorkerType type;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'contact': contact,
    'type': type.name,
  };

  factory Worker.fromJson(Map<String, dynamic> json) => Worker(
    id: json['id'] as String,
    name: json['name'] as String,
    contact: json['contact'] as String? ?? '',
    type: WorkerType.values.firstWhere(
      (value) => value.name == json['type'],
      orElse: () => WorkerType.pakyaw,
    ),
  );
}

class Truck {
  const Truck({required this.id, required this.plate, this.driverId});

  final String id;
  final String plate;
  final String? driverId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'plate': plate,
    'driverId': driverId,
  };

  factory Truck.fromJson(Map<String, dynamic> json) => Truck(
    id: json['id'] as String,
    plate: json['plate'] as String,
    driverId: json['driverId'] as String?,
  );
}

class PayrollLine {
  const PayrollLine({
    required this.workerId,
    required this.workerName,
    required this.gross,
    this.deduction = 0,
  });

  final String workerId;
  final String workerName;
  final double gross;
  final double deduction;
  double get net => gross - deduction;

  Map<String, dynamic> toJson() => {
    'workerId': workerId,
    'workerName': workerName,
    'gross': gross,
    'deduction': deduction,
  };

  factory PayrollLine.fromJson(Map<String, dynamic> json) => PayrollLine(
    workerId: json['workerId'] as String,
    workerName: json['workerName'] as String,
    gross: (json['gross'] as num).toDouble(),
    deduction: (json['deduction'] as num? ?? 0).toDouble(),
  );
}

class PayrollRecord {
  const PayrollRecord({
    required this.id,
    required this.kind,
    required this.date,
    required this.reference,
    required this.description,
    required this.lines,
    this.destination = '',
    this.truckPlate = '',
    this.tripCount = 0,
    this.ratePerTrip = 0,
  });

  final String id;
  final String kind;
  final DateTime date;
  final String reference;
  final String description;
  final List<PayrollLine> lines;
  final String destination;
  final String truckPlate;
  final int tripCount;
  final double ratePerTrip;

  double get totalGross => lines.fold(0, (total, line) => total + line.gross);
  double get totalDeduction =>
      lines.fold(0, (total, line) => total + line.deduction);
  double get totalNet => lines.fold(0, (total, line) => total + line.net);

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'date': date.toIso8601String(),
    'reference': reference,
    'description': description,
    'lines': lines.map((line) => line.toJson()).toList(),
    'destination': destination,
    'truckPlate': truckPlate,
    'tripCount': tripCount,
    'ratePerTrip': ratePerTrip,
  };

  factory PayrollRecord.fromJson(Map<String, dynamic> json) => PayrollRecord(
    id: json['id'] as String,
    kind: json['kind'] as String,
    date: DateTime.parse(json['date'] as String),
    reference: json['reference'] as String? ?? '',
    description: json['description'] as String? ?? '',
    lines: (json['lines'] as List<dynamic>)
        .map((line) => PayrollLine.fromJson(line as Map<String, dynamic>))
        .toList(),
    destination: json['destination'] as String? ?? '',
    truckPlate: json['truckPlate'] as String? ?? '',
    tripCount: json['tripCount'] as int? ?? 0,
    ratePerTrip: (json['ratePerTrip'] as num? ?? 0).toDouble(),
  );
}
