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

  // ─── Pricing ────────────────────────────────────────────────────────────────

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

  // ─── Création ───────────────────────────────────────────────────────────────

  Future<Mission> createMission({
    required String category,
    required String address,
    required String timeSlot,
    required String note,
    required bool isExpress,
  }) async {
    final user = _authService.currentUser;

    if (user == null) throw Exception('Utilisateur non connecté');
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

  // ─── Queries ─────────────────────────────────────────────────────────────────

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

  // ─── Acceptation ─────────────────────────────────────────────────────────────

  Future<void> acceptMission(String missionId) async {
    final user = _authService.currentUser;

    if (user == null) throw Exception('Utilisateur non connecté');
    if (user.role != UserRole.agent) {
      throw Exception('Seul un agent peut accepter une mission');
    }

    final index = _missions.indexWhere((m) => m.id == missionId);
    if (index == -1) throw Exception('Mission introuvable');

    final mission = _missions[index];

    if (mission.status != MissionStatus.created || mission.agentId != null) {
      throw Exception('Mission déjà prise');
    }

    _missions[index] = mission.copyWith(
      agentId: user.id,
      status: MissionStatus.accepted,
    );
  }

  // ─── Progression statut (agent uniquement) ───────────────────────────────────

  Future<void> updateMissionStatus(
    String missionId,
    MissionStatus newStatus,
  ) async {
    final user = _authService.currentUser;

    if (user == null) throw Exception('Utilisateur non connecté');
    if (user.role != UserRole.agent) {
      throw Exception('Seul un agent peut modifier le statut');
    }

    final index = _missions.indexWhere((m) => m.id == missionId);
    if (index == -1) throw Exception('Mission introuvable');

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

    // Transitions autorisées — ordre strict, pas de saut
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

  // ─── Annulation — règles métier différenciées par rôle ───────────────────────
  //
  //  Client  → peut annuler si : created, accepted
  //            ne peut PAS si  : onTheWay, inProgress, completed, cancelled
  //
  //  Agent   → peut annuler si : accepted seulement
  //            ne peut PAS si  : onTheWay, inProgress, completed, cancelled
  //
  //  Personne ne peut annuler une mission completed ou déjà cancelled.

  Future<void> cancelMission(String missionId) async {
    final user = _authService.currentUser;

    if (user == null) throw Exception('Utilisateur non connecté');

    final index = _missions.indexWhere((m) => m.id == missionId);
    if (index == -1) throw Exception('Mission introuvable');

    final mission = _missions[index];

    if (mission.status == MissionStatus.completed) {
      throw Exception('Impossible d\'annuler une mission terminée');
    }
    if (mission.status == MissionStatus.cancelled) {
      throw Exception('Mission déjà annulée');
    }

    if (user.role == UserRole.client) {
      if (mission.clientId != user.id) {
        throw Exception('Vous ne pouvez pas annuler cette mission');
      }
      // Client bloqué dès que l'agent est en route
      if (mission.status == MissionStatus.onTheWay ||
          mission.status == MissionStatus.inProgress) {
        throw Exception(
          'Annulation impossible : l\'agent est déjà en route ou en cours de mission',
        );
      }
    } else if (user.role == UserRole.agent) {
      if (mission.agentId != user.id) {
        throw Exception('Vous ne pouvez pas annuler cette mission');
      }
      // Agent ne peut annuler que si accepted — pas après
      if (mission.status != MissionStatus.accepted) {
        throw Exception(
          'Vous ne pouvez annuler qu\'une mission au statut "Acceptée"',
        );
      }
    } else {
      throw Exception('Rôle non autorisé à annuler une mission');
    }

    _missions[index] = mission.copyWith(status: MissionStatus.cancelled);
  }

  /// Indique si l'utilisateur courant peut annuler cette mission (pour UI).
  bool canCancel(Mission mission) {
    final user = _authService.currentUser;
    if (user == null) return false;
    if (mission.status == MissionStatus.completed ||
        mission.status == MissionStatus.cancelled) return false;

    if (user.role == UserRole.client) {
      return mission.clientId == user.id &&
          (mission.status == MissionStatus.created ||
              mission.status == MissionStatus.accepted);
    }
    if (user.role == UserRole.agent) {
      return mission.agentId == user.id &&
          mission.status == MissionStatus.accepted;
    }
    return false;
  }

  // ─── Preuve ──────────────────────────────────────────────────────────────────

  Future<void> addProof({
    required String missionId,
    required String imagePath,
    required String comment,
  }) async {
    final user = _authService.currentUser;

    if (user == null) throw Exception('Utilisateur non connecté');
    if (user.role != UserRole.agent) {
      throw Exception('Seul un agent peut ajouter une preuve');
    }

    final index = _missions.indexWhere((m) => m.id == missionId);
    if (index == -1) throw Exception('Mission introuvable');

    final mission = _missions[index];

    if (mission.agentId != user.id) {
      throw Exception('Vous ne pouvez ajouter une preuve que sur vos missions');
    }
    if (mission.status == MissionStatus.cancelled) {
      throw Exception('Impossible d\'ajouter une preuve à une mission annulée');
    }
    if (mission.status != MissionStatus.inProgress &&
        mission.status != MissionStatus.completed) {
      throw Exception(
        'Preuve disponible seulement en cours ou terminée',
      );
    }
    if (comment.trim().isEmpty) {
      throw Exception('Le commentaire de preuve est obligatoire');
    }

    _missions[index] = mission.copyWith(
      proof: Proof(imagePath: imagePath, comment: comment.trim()),
    );
  }

  // ─── Rating (client après completed) ─────────────────────────────────────────

  Future<void> rateMission({
    required String missionId,
    required int score,
    String? comment,
  }) async {
    final user = _authService.currentUser;

    if (user == null) throw Exception('Utilisateur non connecté');
    if (user.role != UserRole.client) {
      throw Exception('Seul le client peut noter une mission');
    }

    if (score < 1 || score > 5) {
      throw Exception('La note doit être entre 1 et 5');
    }

    final index = _missions.indexWhere((m) => m.id == missionId);
    if (index == -1) throw Exception('Mission introuvable');

    final mission = _missions[index];

    if (mission.clientId != user.id) {
      throw Exception('Vous ne pouvez noter que vos propres missions');
    }
    if (mission.status != MissionStatus.completed) {
      throw Exception('Vous ne pouvez noter qu\'une mission terminée');
    }
    if (mission.ratingScore != null) {
      throw Exception('Mission déjà notée');
    }

    _missions[index] = mission.copyWith(
      ratingScore: score,
      ratingComment: comment?.trim(),
    );
  }

  /// Indique si le client peut noter cette mission.
  bool canRate(String missionId) {
    final mission = getMissionById(missionId);
    if (mission == null) return false;
    final user = _authService.currentUser;
    if (user == null || user.role != UserRole.client) return false;
    return mission.status == MissionStatus.completed &&
        mission.ratingScore == null &&
        mission.clientId == user.id;
  }
}