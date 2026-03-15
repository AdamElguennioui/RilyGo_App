import 'proof.dart';

enum MissionStatus {
  created,
  accepted,
  onTheWay,
  inProgress,
  completed,
}

class Mission {
  final String id;
  final String category;
  final String address;
  final String timeSlot;
  final String note;
  final MissionStatus status;
  final String clientId;
  final String? agentId;
  final Proof? proof;

  const Mission({
    required this.id,
    required this.category,
    required this.address,
    required this.timeSlot,
    required this.note,
    required this.status,
    required this.clientId,
    this.agentId,
    this.proof,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] as String,
      category: json['category'] as String,
      address: json['address'] as String,
      timeSlot: json['timeSlot'] as String,
      note: json['note'] as String,
      status: _statusFromString(json['status'] as String),
      clientId: json['clientId'] as String,
      agentId: json['agentId'] as String?,
      proof: json['proof'] != null
          ? Proof.fromJson(json['proof'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'address': address,
      'timeSlot': timeSlot,
      'note': note,
      'status': status.name,
      'clientId': clientId,
      'agentId': agentId,
      'proof': proof?.toJson(),
    };
  }

  Mission copyWith({
    String? id,
    String? category,
    String? address,
    String? timeSlot,
    String? note,
    MissionStatus? status,
    String? clientId,
    String? agentId,
    Proof? proof,
  }) {
    return Mission(
      id: id ?? this.id,
      category: category ?? this.category,
      address: address ?? this.address,
      timeSlot: timeSlot ?? this.timeSlot,
      note: note ?? this.note,
      status: status ?? this.status,
      clientId: clientId ?? this.clientId,
      agentId: agentId ?? this.agentId,
      proof: proof ?? this.proof,
    );
  }

  static MissionStatus _statusFromString(String value) {
    switch (value) {
      case 'accepted':
        return MissionStatus.accepted;
      case 'onTheWay':
        return MissionStatus.onTheWay;
      case 'inProgress':
        return MissionStatus.inProgress;
      case 'completed':
        return MissionStatus.completed;
      case 'created':
      default:
        return MissionStatus.created;
    }
  }
}