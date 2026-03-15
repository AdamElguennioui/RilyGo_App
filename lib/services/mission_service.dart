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

  Future<Mission> createMission({
    required String category,
    required String address,
    required String timeSlot,
    required String note,
  }) async {
    final user = _authService.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    if (user.role != UserRole.client) {
      throw Exception('Seul un client peut créer une mission');
    }

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
        .where((m) =>
            m.status == MissionStatus.created && m.agentId == null)
        .toList();
  }

  List<Mission> getAgentMissions(String agentId) {
    return _missions.where((m) => m.agentId == agentId).toList();
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
    MissionStatus status,
  ) async {
    final user = _authService.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    final index = _missions.indexWhere((m) => m.id == missionId);

    if (index == -1) {
      throw Exception('Mission introuvable');
    }

    final mission = _missions[index];

    if (mission.agentId != user.id) {
      throw Exception('Vous ne pouvez modifier que vos propres missions');
    }

    _missions[index] = mission.copyWith(status: status);
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

    final index = _missions.indexWhere((m) => m.id == missionId);

    if (index == -1) {
      throw Exception('Mission introuvable');
    }

    final mission = _missions[index];

    if (mission.agentId != user.id) {
      throw Exception('Vous ne pouvez ajouter une preuve que sur vos missions');
    }

    final proof = Proof(
      imagePath: imagePath,
      comment: comment,
    );

    _missions[index] = mission.copyWith(
      proof: proof,
      status: MissionStatus.completed,
    );
  }

  Mission? getMissionById(String missionId) {
    try {
      return _missions.firstWhere((m) => m.id == missionId);
    } catch (_) {
      return null;
    }
  }
}