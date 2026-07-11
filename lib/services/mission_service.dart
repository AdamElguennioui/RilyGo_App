import '../data/local/local_storage_service.dart';
import '../models/mission.dart';
import '../models/proof.dart';
import '../models/user.dart';
import 'auth_service.dart';

class MissionService {
  static final MissionService _instance = MissionService._internal();
  factory MissionService() => _instance;

  MissionService._internal() {
    final saved = LocalStorageService().loadMissions();
    if (saved != null && saved.isNotEmpty) {
      _missions.addAll(saved);
      // Keep counter above the highest existing id to avoid collisions.
      _counter = _missions.length + 10;
    } else {
      _missions.addAll(_seedMissions);
      _persist(); // save seeds so next launch restores them
    }
  }

  final AuthService _auth = AuthService();
  final List<Mission> _missions = [];
  int _counter = 10;

  List<Mission> get missions => List.unmodifiable(_missions);

  // Fire-and-forget persist after every mutation.
  void _persist() => LocalStorageService().saveMissions(List.of(_missions));

  // ── Seed data ─────────────────────────────────────────────────────────────

  static final List<Mission> _seedMissions = [
    Mission(
      id: 'seed_1',
      category: 'Administration personnelle',
      address: '14 Rue Ibn Battouta, Casablanca',
      timeSlot: 'Lun. 7 juil. — 09h00',
      note: 'Renouvellement CNI. Pièces déjà scannées et envoyées.',
      status: MissionStatus.inProgress,
      clientId: 'client_1',
      agentId: 'agent_1',
      basePrice: 149,
      isExpress: false,
      totalPrice: 149,
    ),
    Mission(
      id: 'seed_2',
      category: 'Démarches mobilité',
      address: '3 Bd Mohammed V, Rabat',
      timeSlot: 'Mar. 8 juil. — 14h00',
      note: 'Changement de titulaire carte grise suite à vente véhicule.',
      status: MissionStatus.created,
      clientId: 'client_2',
      agentId: null,
      basePrice: 199,
      isExpress: true,
      totalPrice: 249,
    ),
    Mission(
      id: 'seed_3',
      category: 'Formalités entreprise',
      address: '27 Rue Abderrahmane Sahraoui, Casablanca',
      timeSlot: 'Mer. 9 juil. — 10h00',
      note: 'Dépôt dossier modification siège social au Tribunal de Commerce.',
      status: MissionStatus.completed,
      clientId: 'client_1',
      agentId: 'agent_1',
      basePrice: 299,
      isExpress: false,
      totalPrice: 299,
      proof: Proof(
        imagePath: 'assets/mock_proof.jpg',
        comment: 'Dossier déposé et récépissé remis au guichet.',
      ),
      ratingScore: 5,
      ratingComment: 'Très professionnel, mission accomplie rapidement.',
    ),
    Mission(
      id: 'seed_4',
      category: "File d'attente",
      address: "Préfecture Casablanca-Anfa, Rue Léon l'Africain",
      timeSlot: 'Jeu. 10 juil. — 08h00',
      note: 'Prise de RDV et attente pour renouvellement titre de séjour.',
      status: MissionStatus.accepted,
      clientId: 'client_2',
      agentId: 'agent_1',
      basePrice: 99,
      isExpress: true,
      totalPrice: 149,
    ),
  ];

  // ── Pricing ───────────────────────────────────────────────────────────────

  double _basePrice(String category) {
    switch (category.trim()) {
      case 'Administration personnelle': return 149;
      case 'Démarches mobilité':         return 199;
      case 'Formalités entreprise':      return 299;
      case 'Immigration & consulaire':   return 249;
      case "File d'attente":             return 99;
      case 'Notariat & légalisation':    return 199;
      // legacy
      case 'Document':    return 149;
      case 'Petit colis': return 199;
      case 'Grand colis': return 299;
      default:            return 149;
    }
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  List<Mission> getClientMissions(String clientId) =>
      _missions.where((m) => m.clientId == clientId).toList();

  List<Mission> getAvailableMissions() =>
      _missions.where((m) => m.status == MissionStatus.created && m.agentId == null).toList();

  List<Mission> getAgentMissions(String agentId) =>
      _missions.where((m) => m.agentId == agentId).toList();

  Mission? getMissionById(String id) {
    try {
      return _missions.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<Mission> createMission({
    required String category,
    required String address,
    required String timeSlot,
    required String note,
    required bool isExpress,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');
    if (user.role != UserRole.client) throw Exception('Seul un client peut créer une mission');

    final base  = _basePrice(category);
    final total = isExpress ? base + 50 : base;

    final mission = Mission(
      id: 'mission_$_counter',
      category: category,
      address: address,
      timeSlot: timeSlot,
      note: note,
      status: MissionStatus.created,
      clientId: user.id,
      basePrice: base,
      isExpress: isExpress,
      totalPrice: total,
    );

    _counter++;
    _missions.add(mission);
    _persist();
    return mission;
  }

  // ── Accept ────────────────────────────────────────────────────────────────

  Future<void> acceptMission(String missionId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');
    if (user.role != UserRole.agent) throw Exception('Seul un agent peut accepter une mission');

    final i = _indexOf(missionId);
    final m = _missions[i];

    if (m.status != MissionStatus.created || m.agentId != null) {
      throw Exception('Mission déjà prise');
    }

    _missions[i] = m.copyWith(agentId: user.id, status: MissionStatus.accepted);
    _persist();
  }

  // ── Status ────────────────────────────────────────────────────────────────

  Future<void> updateMissionStatus(String missionId, MissionStatus newStatus) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');
    if (user.role != UserRole.agent) throw Exception('Seul un agent peut modifier le statut');

    final i = _indexOf(missionId);
    final m = _missions[i];

    if (m.agentId != user.id) throw Exception('Vous ne pouvez modifier que vos propres missions');
    if (m.status == MissionStatus.completed) throw Exception('Mission déjà terminée');
    if (m.status == MissionStatus.cancelled) throw Exception('Mission déjà annulée');

    final valid =
        (m.status == MissionStatus.accepted   && newStatus == MissionStatus.onTheWay) ||
        (m.status == MissionStatus.onTheWay   && newStatus == MissionStatus.inProgress) ||
        (m.status == MissionStatus.inProgress && newStatus == MissionStatus.completed);

    if (!valid) throw Exception('Transition de statut invalide');

    if (newStatus == MissionStatus.completed && m.proof == null) {
      throw Exception('Ajoutez une preuve avant de terminer la mission');
    }

    _missions[i] = m.copyWith(status: newStatus);
    _persist();
  }

  // ── Cancel ────────────────────────────────────────────────────────────────

  Future<void> cancelMission(String missionId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final i = _indexOf(missionId);
    final m = _missions[i];

    if (m.status == MissionStatus.completed) throw Exception("Impossible d'annuler une mission terminée");
    if (m.status == MissionStatus.cancelled) throw Exception('Mission déjà annulée');

    if (user.role == UserRole.client) {
      if (m.clientId != user.id) throw Exception('Vous ne pouvez pas annuler cette mission');
      if (m.status == MissionStatus.onTheWay || m.status == MissionStatus.inProgress) {
        throw Exception("Annulation impossible : l'agent est déjà en route ou en cours de mission");
      }
    } else if (user.role == UserRole.agent) {
      if (m.agentId != user.id) throw Exception('Vous ne pouvez pas annuler cette mission');
      if (m.status != MissionStatus.accepted) {
        throw Exception('Vous ne pouvez annuler qu\'une mission au statut "Acceptée"');
      }
    } else {
      throw Exception('Rôle non autorisé à annuler une mission');
    }

    _missions[i] = m.copyWith(status: MissionStatus.cancelled);
    _persist();
  }

  bool canCancel(Mission mission) {
    final user = _auth.currentUser;
    if (user == null) return false;
    if (mission.status == MissionStatus.completed || mission.status == MissionStatus.cancelled) {
      return false;
    }
    if (user.role == UserRole.client) {
      return mission.clientId == user.id &&
          (mission.status == MissionStatus.created || mission.status == MissionStatus.accepted);
    }
    if (user.role == UserRole.agent) {
      return mission.agentId == user.id && mission.status == MissionStatus.accepted;
    }
    return false;
  }

  // ── Proof ─────────────────────────────────────────────────────────────────

  Future<void> addProof({
    required String missionId,
    required String imagePath,
    required String comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');
    if (user.role != UserRole.agent) throw Exception('Seul un agent peut ajouter une preuve');

    final i = _indexOf(missionId);
    final m = _missions[i];

    if (m.agentId != user.id) throw Exception('Vous ne pouvez ajouter une preuve que sur vos missions');
    if (m.status == MissionStatus.cancelled) throw Exception("Impossible d'ajouter une preuve à une mission annulée");
    if (m.status != MissionStatus.inProgress && m.status != MissionStatus.completed) {
      throw Exception('Preuve disponible seulement en cours ou terminée');
    }
    if (comment.trim().isEmpty) throw Exception('Le commentaire de preuve est obligatoire');

    _missions[i] = m.copyWith(proof: Proof(imagePath: imagePath, comment: comment.trim()));
    _persist();
  }

  // ── Rating ────────────────────────────────────────────────────────────────

  Future<void> rateMission({
    required String missionId,
    required int score,
    String? comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');
    if (user.role != UserRole.client) throw Exception('Seul le client peut noter une mission');
    if (score < 1 || score > 5) throw Exception('La note doit être entre 1 et 5');

    final i = _indexOf(missionId);
    final m = _missions[i];

    if (m.clientId != user.id) throw Exception('Vous ne pouvez noter que vos propres missions');
    if (m.status != MissionStatus.completed) throw Exception('Vous ne pouvez noter qu\'une mission terminée');
    if (m.ratingScore != null) throw Exception('Mission déjà notée');

    _missions[i] = m.copyWith(ratingScore: score, ratingComment: comment?.trim());
    _persist();
  }

  bool canRate(String missionId) {
    final m = getMissionById(missionId);
    if (m == null) return false;
    final user = _auth.currentUser;
    if (user == null || user.role != UserRole.client) return false;
    return m.status == MissionStatus.completed && m.ratingScore == null && m.clientId == user.id;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  int _indexOf(String missionId) {
    final i = _missions.indexWhere((m) => m.id == missionId);
    if (i == -1) throw Exception('Mission introuvable');
    return i;
  }
}
