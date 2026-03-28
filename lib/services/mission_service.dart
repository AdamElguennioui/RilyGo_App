import '../models/mission.dart';
import '../models/proof.dart';
import '../models/user.dart';
import 'auth_service.dart';

class MissionService {
  static final MissionService _instance = MissionService._internal();

  factory MissionService() {
    return _instance;
  }

  MissionService._internal();

  final List<Mission> _missions = [];
  int _counter = 1;

  final AuthService _authService = AuthService();

  List<Mission> get missions => List.unmodifiable(_missions);

  double _getBasePrice(String category) {
    switch (category.trim().toLowerCase()) {
      case 'document':
        return 20;
      case 'petit colis':
        return 30;
      default:
        return 40;
    }
  }

  Future<Mission> createMission({
    required String category,
    required String address,
    required String timeSlot,
    required String note,
    required bool isExpress,
  }) async {
    final user = _authService.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    if (user.role != UserRole.client) {
      throw Exception('Seul un client peut créer une mission');
    }

    final basePrice = _getBasePrice(category);
    final totalPrice = isExpress ? basePrice + 15 : basePrice;

    final mission = Mission(
      id: 'mission_$_counter',
      category: category,
      address: address,
      timeSlot: timeSlot,
      note: note,
      status: MissionStatus.created,
      clientId: user.id,
      agentId: null,
      proof: null,
      basePrice: basePrice,
      isExpress: isExpress,
      totalPrice: totalPrice,
    );

    _counter++;
    _missions.add(mission);

    return mission;
  }

  List<Mission> getClientMissions(String clientId) {
    return _missions.where((m) => m.clientId == clientId).toList();
  }

  List<Mission> getAvailableMissions() {
    return _missions
        .where((m) => m.status == MissionStatus.created && m.agentId == null)
        .toList();
  }

  List<Mission> getAgentMissions(String agentId) {
    return _missions.where((m) => m.agentId == agentId).toList();
  }

  Mission? getMissionById(String missionId) {
    try {
      return _missions.firstWhere((m) => m.id == missionId);
    } catch (_) {
      return null;
    }
  }

  Future<void> acceptMission(String missionId) async {
    final user = _authService.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    if (user.role != UserRole.agent) {
      throw Exception('Seul un agent peut accepter une mission');
    }

    final index = _missions.indexWhere((m) => m.id == missionId);

    if (index == -1) {
      throw Exception('Mission introuvable');
    }

    final mission = _missions[index];

    if (mission.status != MissionStatus.created || mission.agentId != null) {
      throw Exception('Mission déjà prise');
    }

    _missions[index] = mission.copyWith(
      agentId: user.id,
      status: MissionStatus.accepted,
    );
  }

  Future<void> updateMissionStatus(
    String missionId,
    MissionStatus newStatus,
  ) async {
    final user = _authService.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    if (user.role != UserRole.agent) {
      throw Exception('Seul un agent peut modifier une mission');
    }

    final index = _missions.indexWhere((m) => m.id == missionId);

    if (index == -1) {
      throw Exception('Mission introuvable');
    }

    final mission = _missions[index];

    if (mission.agentId != user.id) {
      throw Exception('Vous ne pouvez modifier que vos propres missions');
    }

    if (mission.status == MissionStatus.completed) {
      throw Exception('Mission déjà terminée');
    }

    if (mission.status == MissionStatus.cancelled) {
      throw Exception('Mission déjà annulée');
    }

    final bool isValidTransition =
        (mission.status == MissionStatus.accepted &&
                newStatus == MissionStatus.onTheWay) ||
            (mission.status == MissionStatus.onTheWay &&
                newStatus == MissionStatus.inProgress) ||
            (mission.status == MissionStatus.inProgress &&
                newStatus == MissionStatus.completed);

    if (!isValidTransition) {
      throw Exception('Transition de statut invalide');
    }

    if (mission.status == MissionStatus.inProgress &&
        newStatus == MissionStatus.completed &&
        mission.proof == null) {
      throw Exception('Ajoutez une preuve avant de terminer la mission');
    }

    _missions[index] = mission.copyWith(status: newStatus);
  }

  Future<void> addProof({
    required String missionId,
    required String imagePath,
    required String comment,
  }) async {
    final user = _authService.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    if (user.role != UserRole.agent) {
      throw Exception('Seul un agent peut ajouter une preuve');
    }

    final index = _missions.indexWhere((m) => m.id == missionId);

    if (index == -1) {
      throw Exception('Mission introuvable');
    }

    final mission = _missions[index];

    if (mission.agentId != user.id) {
      throw Exception('Vous ne pouvez ajouter une preuve que sur vos missions');
    }

    if (mission.status == MissionStatus.cancelled) {
      throw Exception('Impossible d’ajouter une preuve à une mission annulée');
    }

    if (mission.status != MissionStatus.inProgress &&
        mission.status != MissionStatus.completed) {
      throw Exception(
        'Vous pouvez ajouter une preuve seulement quand la mission est en cours ou terminée',
      );
    }

    if (comment.trim().isEmpty) {
      throw Exception('Le commentaire de preuve est obligatoire');
    }

    final proof = Proof(
      imagePath: imagePath,
      comment: comment.trim(),
    );

    _missions[index] = mission.copyWith(
      proof: proof,
    );
  }

  Future<void> cancelMission(String missionId) async {
    final user = _authService.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    final index = _missions.indexWhere((m) => m.id == missionId);

    if (index == -1) {
      throw Exception('Mission introuvable');
    }

    final mission = _missions[index];

    final isClientOwner = mission.clientId == user.id;
    final isAssignedAgent = mission.agentId == user.id;

    if (!isClientOwner && !isAssignedAgent) {
      throw Exception('Vous ne pouvez pas annuler cette mission');
    }

    if (mission.status == MissionStatus.completed) {
      throw Exception('Impossible d’annuler une mission terminée');
    }

    if (mission.status == MissionStatus.cancelled) {
      throw Exception('Mission déjà annulée');
    }

    _missions[index] = mission.copyWith(
      status: MissionStatus.cancelled,
    );
  }

  bool canRateMission(String missionId) {
    final mission = getMissionById(missionId);

    if (mission == null) return false;

    return mission.status == MissionStatus.completed;
  }
}