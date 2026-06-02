class Service {
  final int? id;
  final int clientId;
  final String equipment;
  final String? brand;
  final String? model;
  final String? reportedProblem;
  final String serviceDescription;
  final double value;
  final String status; // "Em andamento" ou "Concluído"
  final String createdAt;

  Service({
    this.id,
    required this.clientId,
    required this.equipment,
    this.brand,
    this.model,
    this.reportedProblem,
    required this.serviceDescription,
    required this.value,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'equipment': equipment,
      'brand': brand,
      'model': model,
      'reportedProblem': reportedProblem,
      'serviceDescription': serviceDescription,
      'value': value,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      clientId: map['clientId'],
      equipment: map['equipment'],
      brand: map['brand'],
      model: map['model'],
      reportedProblem: map['reportedProblem'],
      serviceDescription: map['serviceDescription'],
      value: map['value'],
      status: map['status'],
      createdAt: map['createdAt'],
    );
  }
}
