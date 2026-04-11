import 'proof.dart';

enum MissionStatus {
  created,
  accepted,
  onTheWay,
  inProgress,
  completed,
  cancelled,
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
  final double basePrice;
  final bool isExpress;
  final double totalPrice;

  // Rating — rempli par le client après completed
  final int? ratingScore;       // 1 à 5
  final String? ratingComment;  // optionnel

  const Mission({
    required this.id,
    required this.category,
    required this.address,
    required this.timeSlot,
    required this.note,
    required this.status,
    required this.basePrice,
    required this.isExpress,
    required this.totalPrice,
    required this.clientId,
    this.agentId,
    this.proof,
    this.ratingScore,
    this.ratingComment,
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
      basePrice: (json['basePrice'] as num).toDouble(),
      isExpress: json['isExpress'] as bool,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      proof: json['proof'] != null
          ? Proof.fromJson(json['proof'] as Map<String, dynamic>)
          : null,
      ratingScore: json['ratingScore'] as int?,
      ratingComment: json['ratingComment'] as String?,
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
      'basePrice': basePrice,
      'isExpress': isExpress,
      'totalPrice': totalPrice,
      'proof': proof?.toJson(),
      'ratingScore': ratingScore,
      'ratingComment': ratingComment,
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
    double? basePrice,
    bool? isExpress,
    double? totalPrice,
    Proof? proof,
    int? ratingScore,
    String? ratingComment,
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
      basePrice: basePrice ?? this.basePrice,
      isExpress: isExpress ?? this.isExpress,
      totalPrice: totalPrice ?? this.totalPrice,
      proof: proof ?? this.proof,
      ratingScore: ratingScore ?? this.ratingScore,
      ratingComment: ratingComment ?? this.ratingComment,
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
      case 'cancelled':
        return MissionStatus.cancelled;
      case 'created':
      default:
        return MissionStatus.created;
    }
  }
}